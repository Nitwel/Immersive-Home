import { execFileSync } from 'child_process';
import { join, resolve } from 'path';
import { readdir, unlink, readFile, writeFile, mkdir, rm } from 'fs/promises';
import { XMLParser } from 'fast-xml-parser'
import { camelCase } from 'lodash-es'
import { markdownTable } from 'markdown-table'

const DOCS_PATH = process.cwd()
const APP_PATH = resolve(DOCS_PATH, '../app')
const REFERENCE_PATH = join(DOCS_PATH, 'reference')
const RAW_PATH = join(REFERENCE_PATH, 'raw')
const GODOT_DOCS = 'https://docs.godotengine.org/en/stable/classes'

const BUILTIN_TYPES = ['void', 'Variant', 'bool', 'int', 'float', 'String', 'StringName', 'NodePath', 'Array', 'Dictionary', 'Callable', 'Signal', 'Object', 'RID']

// Classes that have their own page in the reference
let documented_classes = new Set<string>()
// Global script classes that are not part of the reference (e.g. from content/ or addons/)
let undocumented_classes = new Set<string>()

main().catch(error => {
    console.error(error)
    process.exit(1)
})

async function main() {
    await export_from_godot()
    await translate()
}

async function export_from_godot() {
    // Godot only adds and overwrites files, so start fresh to drop classes that were removed or renamed.
    await rm(RAW_PATH, { recursive: true, force: true })
    await mkdir(RAW_PATH, { recursive: true })

    try {
        execFileSync(process.env.GODOT_BIN ?? 'godot', ['--headless', '--path', APP_PATH, '--doctool', RAW_PATH, '--gdscript-docs', 'res://lib'], {
            stdio: ['ignore', 'ignore', 'inherit'],
        });
    } catch (error) {
        // Godot may exit with a non-zero code because of unrelated warnings, so only fail if nothing was exported.
        console.log('⚠️ Godot exited with an error: ', (error as Error).message)
    }

    if ((await readdir(RAW_PATH)).filter(file => file.endsWith('.xml')).length === 0) {
        throw new Error('❌ Godot did not export any references. Is Godot 4.6+ available as `godot` (or set GODOT_BIN=<path>)?')
    }

    console.log('✅ Exported from Godot');
}

async function translate() {
    const raw_files = (await readdir(RAW_PATH)).filter(file => file.endsWith('.xml')).sort()

    documented_classes = new Set(raw_files.map(file => {
        file = file.replace('.xml', '')

        if (file.includes('--')) {
            return `"${file.replace(/--/g, '/')}"`
        }

        return file
    }))

    undocumented_classes = await read_global_classes()

    const generated = new Set<string>()

    for (const file of raw_files) {
        const contents = await readFile(join(RAW_PATH, file), 'utf-8')
        const markdown = translate_reference(contents)
        const name = file.replace('.gd', '').replace('.xml', '.md')

        await writeFile(join(REFERENCE_PATH, name), markdown)
        generated.add(name)
    }

    // Every markdown file in the reference folder is generated, remove the ones of classes that no longer exist.
    for (const file of await readdir(REFERENCE_PATH)) {
        if (file.endsWith('.md') && !generated.has(file)) {
            await unlink(join(REFERENCE_PATH, file))
            console.log(`🗑️ Removed outdated ${file}`)
        }
    }

    console.log(`✅ Translated ${generated.size} references to markdown`);
}

async function read_global_classes(): Promise<Set<string>> {
    try {
        const cache = await readFile(join(APP_PATH, '.godot/global_script_class_cache.cfg'), 'utf-8')
        const classes = [...cache.matchAll(/"class": &"(\w+)"/g)].map(match => match[1])

        return new Set(classes.filter(name => !documented_classes.has(name)))
    } catch {
        return new Set()
    }
}

type ClassContext = {
    members: Set<string>,
    methods: Set<string>,
    signals: Set<string>,
    constants: Set<string>,
    enums: Set<string>,
}

function translate_reference(contents: string): string {
    const parser = new XMLParser({
        ignoreAttributes: false,
        attributeNamePrefix: '_',
        isArray: (name) => ['signal', 'constant', 'member', 'method', 'param'].includes(name),
    })
    const json = parser.parse(contents)

    const signals_list = sort_by_name(to_array(json.class.signals?.signal))
    const constants = to_array(json.class.constants?.constant)
    const enum_list = constants.filter(constant => '_enum' in constant)
    const constants_list = sort_by_name(constants.filter(constant => !('_enum' in constant)))
    const members_list = sort_by_name(to_array(json.class.members?.member))
    const methods_list = sort_by_name(to_array(json.class.methods?.method))

    const context: ClassContext = {
        members: new Set(members_list.map(member => member._name)),
        methods: new Set(methods_list.map(method => method._name)),
        signals: new Set(signals_list.map(signal => signal._name)),
        constants: new Set(constants.map(constant => constant._name)),
        enums: new Set(enum_list.map(constant => constant._enum)),
    }

    const text = (value: any) => format_text(value, context)

    let description = ''
    const long_description = text(json.class.description)
    const brief_description = text(json.class.brief_description)

    if (long_description || brief_description) {
        description = '## Description\n\n' + [brief_description, long_description].filter(Boolean).join('\n\n')
    }

    let inherits = ''

    if (json.class._inherits) {
        inherits = `**Inherits:** ${link_godot_type(json.class._inherits)}`
    }

    let signal_descriptions = ''

    if (signals_list.length > 0) {
        signal_descriptions = '## Signals\n\n' +
            signals_list.map(signal => {
                const name = signal._name

                return section(
                    `### ${name} (${format_params(signal.param)} ) ${'{#' + name_to_anchor(name) + '}'}`,
                    text(signal.description)
                )
            }).join('\n\n')
    }

    let enum_descriptions = ''

    if (enum_list.length > 0) {
        const enums: Record<string, any[]> = {}

        for (const constant of enum_list) {
            enums[constant._enum] ??= []
            enums[constant._enum].push(constant)
        }

        enum_descriptions = '## Enums\n\n' + Object.keys(enums).sort().map(enum_name => {
            return `### enum ${enum_name} {#enum-${name_to_anchor(enum_name)}}\n\n` + enums[enum_name].map(constant => {
                const name = constant._name

                return section(
                    `#### ${enum_name}.${name} = \`${constant._value}\` ${'{#const-' + name_to_anchor(name) + '}'}`,
                    text(constant['#text'])
                )
            }).join('\n\n')
        }).join('\n\n')
    }

    let constant_descriptions = ''

    if (constants_list.length > 0) {
        constant_descriptions = '## Constants\n\n' +
            constants_list.map(constant => {
                const name = constant._name

                return section(
                    `### ${name} = ${inline_code(constant._value)} ${'{#const-' + name_to_anchor(name) + '}'}`,
                    text(constant['#text'])
                )
            }).join('\n\n')
    }

    let members = ''
    let member_descriptions = ''

    if (members_list.length > 0) {
        members = '## Properties\n\n' + markdownTable([
            ['Name', 'Type', 'Default'],
            ...members_list.map(member => {
                const name = member._name

                return [
                    `[${name}](#prop-${name_to_anchor(name)})`,
                    link_godot_type(member._type, member._enum, context),
                    handle_default(member._default)
                ]
            })
        ])

        member_descriptions = '## Property Descriptions\n\n' +
            members_list.map(member => {
                const name = member._name

                return section(
                    `### ${name}: ${link_godot_type(member._type, member._enum, context)} ${'{#prop-' + name_to_anchor(name) + '}'}`,
                    text(member['#text'])
                )
            }).join('\n\n')
    }

    let methods = ''
    let method_descriptions = ''

    if (methods_list.length > 0) {
        methods = '## Methods\n\n' + markdownTable([
            ['Returns', 'Name'],
            ...methods_list.map(method => {
                const name = method._name

                return [
                    link_godot_type(method.return?._type, method.return?._enum, context),
                    `[${name}](#${name_to_anchor(name)}) ( ${format_params(method.param, context, '')} )`
                ]
            })
        ])

        method_descriptions = '## Method Descriptions\n\n' +
            methods_list.map(method => {
                const name = method._name
                const qualifiers = method._qualifiers ? method._qualifiers + ' ' : ''

                return section(
                    `### ${qualifiers}${name} (${format_params(method.param, context)} ) -> ${link_godot_type(method.return?._type, method.return?._enum, context)} ${'{#' + name_to_anchor(name) + '}'}`,
                    text(method.description)
                )
            }).join('\n\n')
    }

    const sections = [
        `# ${getTitle(json.class._name)}` + (inherits ? '\n' + inherits : ''),
        description,
        members,
        methods,
        signal_descriptions,
        enum_descriptions,
        constant_descriptions,
        member_descriptions,
        method_descriptions,
    ]

    return sections.filter(Boolean).join('\n\n') + '\n'
}

function section(heading: string, body: string): string {
    return `${heading}\n\n${body || 'No description provided yet.'}`
}

function format_params(params: any, context?: ClassContext, separator = ' '): string {
    return to_array(params)
        .sort((a, b) => Number(a._index) - Number(b._index))
        .map(param => {
            const default_value = param._default !== undefined ? ` = ${inline_code(param._default)}` : ''
            return `${param._name}: ${link_godot_type(param._type, param._enum, context)}${default_value}${separator}`
        })
        .join(', ')
}

function sort_by_name<T extends { _name: string }>(list: T[]): T[] {
    // Godot exports in source order since 4.4, keep the reference alphabetical so diffs stay small.
    return [...list].sort((a, b) => a._name < b._name ? -1 : a._name > b._name ? 1 : 0)
}

/**
 * Converts the BBCode used in Godot doc comments into markdown.
 * https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html#bbcode-and-class-reference
 */
function format_text(value: any, context: ClassContext): string {
    if (value === undefined || value === null) {
        return ''
    }

    let text = dedent(String(value))

    const code_blocks: string[] = []
    const stash = (markdown: string) => {
        code_blocks.push(markdown)
        return `\u0000${code_blocks.length - 1}\u0000`
    }

    text = text.replace(/\[codeblocks?\]([\s\S]*?)\[\/codeblocks?\]/g, (_, code) => {
        const gdscript = /\[gdscript\]([\s\S]*?)\[\/gdscript\]/.exec(code)
        return stash('```gdscript\n' + dedent(gdscript ? gdscript[1] : code) + '\n```')
    })
    text = text.replace(/\[codeblock lang=(\w+)\]([\s\S]*?)\[\/codeblock\]/g, (_, lang, code) => stash('```' + lang + '\n' + dedent(code) + '\n```'))
    text = text.replace(/\[code\]([\s\S]*?)\[\/code\]/g, (_, code) => stash(inline_code(code)))

    text = text.replace(/\[(param|constant|enum|annotation|theme_item|operator|constructor) ([^\]]+)\]/g, (_, kind, name) => {
        if (kind === 'constant' && context.constants.has(name)) {
            return stash(`[${inline_code(name)}](#const-${name_to_anchor(name)})`)
        }
        if (kind === 'enum' && context.enums.has(name)) {
            return stash(`[${inline_code(name)}](#enum-${name_to_anchor(name)})`)
        }

        return stash(inline_code(name))
    })

    text = text.replace(/\[(member|method|signal) ([^\]]+)\]/g, (_, kind: 'member' | 'method' | 'signal', name: string) => {
        const label = kind === 'method' ? name + '()' : name
        const local = { member: context.members, method: context.methods, signal: context.signals }[kind]
        const anchor = (kind === 'member' ? 'prop-' : '') + name_to_anchor(name.split('.').at(-1)!)

        if (local.has(name)) {
            return stash(`[${inline_code(label)}](#${anchor})`)
        }

        const class_name = name.includes('.') ? name.split('.').slice(0, -1).join('.') : ''
        if (class_name && documented_classes.has(class_name)) {
            return stash(`[${inline_code(label)}](${class_page(class_name)}#${anchor})`)
        }

        return stash(inline_code(label))
    })

    text = text.replace(/\[url=([^\]]+)\]([\s\S]*?)\[\/url\]/g, (_, url, label) => `[${label}](${url})`)
    text = text.replace(/\[url\]([\s\S]*?)\[\/url\]/g, (_, url) => `<${url}>`)
    text = text.replace(/\[\/?b\]/g, '**')
    text = text.replace(/\[\/?i\]/g, '*')
    text = text.replace(/\[\/?u\]/g, '')
    text = text.replace(/\[\/?s\]/g, '~~')
    text = text.replace(/\[kbd\]([\s\S]*?)\[\/kbd\]/g, (_, key) => stash(`<kbd>${key}</kbd>`))
    text = text.replace(/\[br\]/g, '<br>')
    text = text.replace(/\[lb\]/g, '\\[').replace(/\[rb\]/g, '\\]')

    // Class references like [Node3D]
    text = text.replace(/\[([A-Z@][\w.]*)\]/g, (match, type) => {
        if (type.includes('.') || type.startsWith('@') || /^[A-Z0-9_]+$/.test(type)) {
            return match
        }
        return stash(link_godot_type(type))
    })

    // Prevent Vue from interpreting text as templates
    text = text.replace(/</g, '&lt;').replace(/\{\{/g, '&#123;&#123;')

    return text.replace(/\u0000(\d+)\u0000/g, (_, index) => code_blocks[Number(index)])
}

function dedent(text: string): string {
    const lines = text.replace(/\r\n/g, '\n').split('\n')

    while (lines.length > 0 && lines[0].trim() === '') lines.shift()
    while (lines.length > 0 && lines.at(-1)!.trim() === '') lines.pop()

    const indent = Math.min(...lines.filter(line => line.trim() !== '').map(line => /^\s*/.exec(line)![0].length))

    return lines.map(line => line.slice(Number.isFinite(indent) ? indent : 0).trimEnd()).join('\n')
}

function inline_code(value: string): string {
    value = String(value).replace(/\n/g, ' ')
    const fence = value.includes('`') ? '`` ' : '`'
    return fence + value + fence.split('').reverse().join('')
}

function getTitle(name: string): string {
    name = name.replace(/"/g, '')
    name = name.split(/(?:--|\\|\/)/g).at(-1)!
    name = name.split('.').at(0)!

    return capitalize(camelCase(name))
}

function capitalize(string: string): string {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function name_to_anchor(name: string): string {
    return name.replace(/_/g, '-')
}

function link_godot_type(type?: string, enum_name?: string, context?: ClassContext): string {
    if (!type || type === 'void') {
        return 'void'
    }

    if (enum_name) {
        return link_enum(enum_name, context)
    }

    if (type.endsWith('[]')) {
        return `[Array](${GODOT_DOCS}/class_array.html)\\[${link_godot_type(type.slice(0, -2))}\\]`
    }

    const script = /^"(.*?\.gd)"$/.exec(type)
    if (script) {
        if (documented_classes.has(type)) {
            return `[${getTitle(script[1])}](${class_page(type)})`
        }

        // Scripts outside of lib/ are not part of the reference
        return inline_code(script[1])
    }

    if (documented_classes.has(type)) {
        return `[${getTitle(type)}](${class_page(type)})`
    }

    if (undocumented_classes.has(type)) {
        return inline_code(type)
    }

    return `[${type}](${GODOT_DOCS}/class_${type.toLowerCase().replace(/^@/, '_')}.html)`
}

/** Page of a class that is part of the reference, either a class_name or a quoted script path like "lib/stores/store.gd" */
function class_page(class_name: string): string {
    const page = class_name.replace(/"/g, '').replace('.gd', '').replace(/\//g, '--')
    return `/reference/${page}.html`
}

function link_enum(enum_name: string, context?: ClassContext): string {
    const parts = enum_name.split('.')

    if (parts.length === 1) {
        if (context?.enums.has(enum_name)) {
            return `[${enum_name}](#enum-${name_to_anchor(enum_name)})`
        }

        // Global enums like Key or Error
        return `[${enum_name}](${GODOT_DOCS}/class_@globalscope.html#enum-globalscope-${enum_name.toLowerCase()})`
    }

    const [class_name, name] = [parts.slice(0, -1).join('.'), parts.at(-1)!]

    if (documented_classes.has(class_name)) {
        return `[${getTitle(class_name)}.${name}](${class_page(class_name)}#enum-${name_to_anchor(name)})`
    }

    if (class_name.startsWith('"')) {
        return inline_code(`${class_name.replace(/"/g, '')}.${name}`)
    }

    if (BUILTIN_TYPES.includes(class_name) || /^[A-Z]/.test(class_name) && !undocumented_classes.has(class_name)) {
        return `[${enum_name}](${GODOT_DOCS}/class_${class_name.toLowerCase()}.html#enum-${class_name.toLowerCase()}-${name.toLowerCase()})`
    }

    return inline_code(enum_name)
}

function to_array(object: any): any[] {
    if (!object) {
        return []
    }

    if (Array.isArray(object)) {
        return object
    } else {
        return [object]
    }
}

function handle_default(value: string): string {
    if (value === undefined || value === '' || value === '<unknown>') {
        return ''
    }

    return inline_code(value)
}

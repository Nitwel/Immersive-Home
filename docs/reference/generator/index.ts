import { execSync } from 'child_process';
import { join } from 'path';
import { readdir, unlink, readFile, writeFile, mkdir } from 'fs/promises';
import { XMLParser } from 'fast-xml-parser'
import { camelCase } from 'lodash-es'
import { markdownTable } from 'markdown-table'
import endent from "endent";

const REFERENCE_PATH = './reference/raw'
let custom_types: string[] = []

// export_from_godot()
translate()

async function export_from_godot() {

    try {
        execSync('godot --doctool ../docs/reference/raw --gdscript-docs res://lib ', {
            cwd: join(process.cwd(), '../app/'),
        });
    } catch (error) {
        console.log('⚠️ Ignoring error exporting from Godot: ', error)
    }

    console.log('✅ Exported from Godot');
}

async function translate() {
    custom_types = (await readdir(REFERENCE_PATH)).map(file => {
        file = file.replace('.xml', '').replace(/--/g, '/')

        if (file.includes('--')) {
            return `"${file}.gd"`
        }

        return file
    })


    for (const file of await readdir(REFERENCE_PATH)) {
        const contents = await parse_reference(join(REFERENCE_PATH, file))
        const markdown = translate_reference(contents)
        await save_markdown(join('./reference', file.replace('.gd', '').replace('.xml', '.md')), markdown)
    }

    console.log('✅ Translated references to markdown');
}

async function parse_reference(path: string): Promise<string> {
    return readFile(path, 'utf-8')
}

function translate_reference(contents: string): string {
    const parser = new XMLParser({
        ignoreAttributes: false,
        attributeNamePrefix: '_'
    })
    const json = parser.parse(contents)

    let description = ''

    if (json.class.brief_description) {
        description = endent`
            ## Description
            
            ${json.class.brief_description}
            `
    }

    if (json.class.description) {
        description = endent`
            ## Description

            ${json.class.description}
            `
    }

    let inherits = ''

    if (json.class._inherits) {
        inherits = endent`**Inherits:** ${link_godot_type(json.class._inherits)}`
    }

    let signal_descriptions = ''
    let signals_list = to_array(json.class.signals?.signal)

    if (signals_list.length > 0) {
        signal_descriptions = '## Signals\n\n' +
            signals_list.map(signal => {
                const name = signal._name

                let params = to_array(signal?.param).map(param => {
                    return `${param._name}: ${link_godot_type(param._type)} `
                }).join(', ')

                return endent`
                    ### ${name} (${params} ) ${'{#' + name_to_anchor(name) + '}'}

                    ${signal.description || 'No description provided yet.'}
                `
            }).join('\n\n')
    }


    let constant_descriptions = ''
    let constants_list = to_array(json.class.constants?.constant)

    if (constants_list.length > 0) {
        constant_descriptions = '## Constants\n\n' +
            constants_list.map(constant => {
                const name = constant._name

                console.log('constant', constant._value)

                return `
### ${name} = \`${constant._value}\` ${'{#const-' + name_to_anchor(name) + '}'}

${constant.description || 'No description provided yet.'}
                `
            }).join('\n\n')
    }

    let members = ''
    let member_descriptions = ''
    let members_list = to_array(json.class.members?.member)

    if (members_list.length > 0) {
        members = endent`
            ## Properties

            ${markdownTable([
            ['Name', 'Type', 'Default'],
            ...members_list.map(member => {
                const name = member._name

                return [
                    `[${name}](#${name_to_anchor(name)})`,
                    link_godot_type(member._type),
                    handle_default(member._default)
                ]
            })
        ])
            }
    `

        member_descriptions = '## Property Descriptions\n\n' +
            members_list.map(member => {
                const name = member._name

                return endent`
                ### ${name}: ${link_godot_type(member._type)} ${'{#' + name_to_anchor(name) + '}'}

                ${member.description || 'No description provided yet.'}
    `
            }).join('\n\n')
    }

    let methods = ''
    let method_descriptions = ''
    let methods_list = to_array(json.class.methods?.method)

    if (methods_list.length > 0) {


        methods = endent`
            ## Methods

            ${markdownTable([
            ['Returns', 'Name'],
            ...methods_list.map(method => {
                const name = method._name

                let params = to_array(method?.param).map(param => {
                    return `${param._name}: ${link_godot_type(param._type)}`
                }).join(', ')

                return [
                    link_godot_type(method.return._type),
                    `[${name}](#${name_to_anchor(name)}) ( ${params} )`
                ]
            })
        ])
            }
    `

        method_descriptions = '## Method Descriptions\n\n' +
            methods_list.map(method => {
                const name = method._name

                let params = to_array(method?.param).map(param => {
                    return `${param._name}: ${link_godot_type(param._type)} `
                }).join(', ')

                return endent`
                ### ${name} (${params} ) -> ${link_godot_type(method.return._type)} ${'{#' + name_to_anchor(name) + '}'}

                ${method.description || 'No description provided yet.'}
    `
            }).join('\n\n')
    }

    let markdown = endent`
        # ${getTitle(json.class._name)}
        ${inherits}
            
        ${description}

        ${members}

        ${methods}

        ${signal_descriptions}

        ${constant_descriptions}

        ${member_descriptions}

        ${method_descriptions}

    ` + '\n'

    return markdown
}

async function save_markdown(path: string, markdown: string) {
    return writeFile(path, markdown)
}

function getTitle(name: string): string {
    name = name.split(/(?:--|\\|\/)/g).at(-1)
    name = name.split('.').at(0)

    return capitalize(camelCase(name))
}

function capitalize(string: string): string {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function name_to_anchor(name: string): string {
    return name.replace(/_/g, '-')
}

function link_godot_type(type: string): string {
    if (!type || type === 'void') {
        return 'void'
    }

    if (/"lib\/.*?\.gd"/g.test(type)) {
        return type.replace(/"lib\/.*?\.gd"/, (match) => {
            match = match.replace(/"/g, '')

            const link = match.replace('.gd', '').replace(/\//g, '--')
            return `[${getTitle(match)}](/reference/${link}.html)`
        })
    }

    if (custom_types.includes(type)) {
        return `[${getTitle(type)}](/reference/${type}.html)`
    }

    return `[${type}](https://docs.godotengine.org/de/4.x/classes/class_${type.toLowerCase()}.html)`
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
    if (!value || value === '<unknown>') {
        return ''
    }

    return `\`${value}\``
}
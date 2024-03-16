import fs from 'fs'
import { camelCase } from 'lodash-es'

export default {
    '/': [
        {
            text: 'Getting Started',
            items: [
                {
                    text: 'Quick Start',
                    link: '/'
                },
                {
                    text: 'Introduction',
                    link: '/getting-started/introduction'
                },
                {
                    text: 'Installation',
                    link: '/getting-started/installation'
                }
            ]
        }
    ],
    '/development/': [
        {
            text: 'Development',
            items: [
                {
                    text: 'General',
                    link: '/development/'
                }
            ]
        }
    ],
    '/reference/': getReferenceSidebar()

}

function getReferenceSidebar() {
    const files: Record<string, any>[] = []

    for (const file of fs.readdirSync('./reference')) {
        if (!file.endsWith('.md')) continue

        let path_parts = file.split('--').filter(part => part !== 'lib').map(part => capitalize(part))

        if (path_parts[0].startsWith('Event')) {
            path_parts = ['Events', ...path_parts]
        }

        insert_file(files, path_parts, file)
    }

    function insert_file(tree: Record<string, any>[], path_parts: string[], full_path: string) {
        if (path_parts.length === 1) {
            tree.push({
                text: getTitle(path_parts[0]),
                link: `/reference/${full_path}`
            })
            return
        }

        const part = path_parts.shift()!

        let node = tree.find(node => node.text === part)

        if (!node) {
            node = { text: part, items: [] }
            tree.push(node)
        }

        insert_file(node.items, path_parts, full_path)
    }


    return [
        {
            text: 'Reference',
            items: files
        }
    ]
}

function getTitle(name: string): string {
    name = name.split('--').at(-1)!
    name = name.split('.').at(0)!

    return capitalize(camelCase(name))
}

function capitalize(string: string): string {
    return string.charAt(0).toUpperCase() + string.slice(1);
}
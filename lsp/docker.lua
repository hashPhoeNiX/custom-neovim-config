-- Docker Language Server configuration

return {
  name = 'dockerls',
  cmd = { 'docker-langserver', '--stdio' },
  root_markers = { 'Dockerfile', 'dockerfile', 'Dockerfile.*' },
  filetypes = { 'dockerfile' },

  settings = {
    docker = {
      languageserver = {
        formatter = {
          ignoreMultilineInstructions = true,
        },
      },
    },
  },
}

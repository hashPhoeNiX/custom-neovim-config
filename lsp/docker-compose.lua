-- Docker Compose Language Server configuration

return {
  name = 'docker_compose_language_service',
  cmd = { 'docker-compose-langserver', '--stdio' },
  root_markers = { 'docker-compose.yml', 'docker-compose.yaml', 'compose.yml', 'compose.yaml' },
  filetypes = { 'yaml.docker-compose', 'yaml' },

  settings = {},
}

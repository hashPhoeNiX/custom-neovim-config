-- YAML Language Server configuration

return {
  name = 'yamlls',
  cmd = { 'yaml-language-server', '--stdio' },
  root_markers = { '.git' },
  filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },

  settings = {
    yaml = {
      -- Use schemastore for automatic schema detection
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
      schemas = {
        -- Kubernetes schemas
        ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
        ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.{yml,yaml}",
        -- GitHub Actions
        ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*",
        ["https://json.schemastore.org/github-action.json"] = ".github/actions/*/action.{yml,yaml}",
      },
      format = {
        enable = true,
      },
      validate = true,
      completion = true,
      hover = true,
      -- Disable Red Hat telemetry
      redhat = {
        telemetry = {
          enabled = false,
        },
      },
    },
  },
}

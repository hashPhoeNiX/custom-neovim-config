-- Terraform Language Server configuration

return {
  name = 'terraformls',
  cmd = { 'terraform-ls', 'serve' },
  root_markers = { '.terraform', '*.tf', '*.tfvars' },
  filetypes = { 'terraform', 'terraform-vars', 'hcl' },

  settings = {},
}

require 'open3'
require 'pathname'
require 'yaml'

describe "generating a manifest" do
  let(:dir) { Pathname(File.absolute_path(__dir__) + '/..') }
  let(:manifest_template) { dir.join('manifest.yml').read }

  let(:new_manifest) {
    cmd = dir.join('release', 'generate-manifest')

    stdout, stderr, status = Open3.capture3(
      {
        'CF_API' => 'https://api.foo.bar.baz',
      },
      cmd.to_s,
      stdin_data: manifest_template
    )

    expect(stderr).to be_empty
    YAML.load(stdout)
  }

  it "adds a www.SYSTEM_DOMAIN route" do
    expect(new_manifest['applications'][0]['routes']).
      to include({ 'route' => 'docs.foo.bar.baz' })
  end

  let(:manifest_template) { dir.join('redirect/manifest.yml').read }

  let(:new_redirect_manifest) {
    cmd = dir.join('release', 'generate-redirect-manifest')

    stdout, stderr, status = Open3.capture3(
      {
        'CF_API' => 'https://api.foo.bar.baz',
        'CF_APPS_DOMAIN' => 'apps.foo.bar.baz',
      },
      cmd.to_s,
      stdin_data: manifest_template
    )

    expect(stderr).to be_empty
    YAML.load(stdout)
  }

  it "adds the apps route" do
    expect(new_redirect_manifest['applications'][0]['routes']).
      to include({ 'route' => 'paas-tech-docs.apps.foo.bar.baz' })
  end

  it "sets the REDIRECT_DOMAIN environment variable" do
    expect(new_redirect_manifest['applications'][0]['env']).
      to include({ 'REDIRECT_DOMAIN' => 'docs.foo.bar.baz' })
  end
end

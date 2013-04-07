require 'spec_helper'

describe 'boxen::osx_defaults' do
  let(:title)  { 'example' }
  let(:domain) { 'com.example' }
  let(:key)    { 'testkey' }
  let(:value)  { 'yes' }

  let(:params) {
    { :domain => domain,
      :key    => key,
      :value  => value,
    }
  }

  it do
    should contain_exec("osx_defaults write  #{domain}:#{key}=>#{value}").
      with(:command => "/usr/bin/defaults write #{domain} #{key} #{value}")
  end

  context 'with quoting for shell values' do
    let(:domain) { 'NSGlobalDomain With Space' }
    let(:key)    { 'Key With Spaces' }
    let(:value)  { 'Long String With Spaces' }
    let(:host)   { 'com.example.long/host' }

    let(:default_params) {
      { :domain => domain,
        :key    => key,
        :value  => value,
        :host   => host
      }
    }
    let(:params) { default_params }

    context "for writing" do
      it do
        should contain_exec("osx_defaults write #{host} #{domain}:#{key}=>#{value}").
          with(:command => "/usr/bin/defaults -host #{host} write \"#{domain}\" \"#{key}\" \"#{value}\"")
      end
    end

    context "for deleting" do
      let(:params) { default_params.merge(:ensure => 'delete') }

      it do
        should contain_exec("osx_defaults delete #{host} #{domain}:#{key}").
          with(:command => "/usr/bin/defaults -host #{host} delete \"#{domain}\" \"#{key}\"")
      end
    end
  end

  context "with a host" do
    let(:params) {
      { :domain => domain,
        :key    => key,
        :value  => value,
        :host   => host
      }
    }

    context "currentHost" do
      let(:host) { 'currentHost' }

      it do
        should contain_exec("osx_defaults write #{host} #{domain}:#{key}=>#{value}").
          with(:command => "/usr/bin/defaults -currentHost write #{domain} #{key} #{value}")
      end
    end

    context "specific host" do
      let(:host) { 'mybox.example.com' }

      it do
        should contain_exec("osx_defaults write #{host} #{domain}:#{key}=>#{value}").
          with(:command => "/usr/bin/defaults -host #{host} write #{domain} #{key} #{value}")
      end
    end
  end
end

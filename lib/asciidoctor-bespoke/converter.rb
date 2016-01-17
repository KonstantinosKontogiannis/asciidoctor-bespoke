require 'asciidoctor/converter/html5'
require 'asciidoctor/converter/composite'
require 'asciidoctor/converter/template'

# 1.5.4 does not recognize svg tag name if immediately followed by newline
Asciidoctor::Converter::Html5Converter.tap do |klass|
  klass.send :remove_const, :SvgPreambleRx
  klass.const_set :SvgPreambleRx, /\A.*?(?=<svg\b)/m
end if Asciidoctor::VERSION == '1.5.4'

module Asciidoctor
module Bespoke
  class Converter < ::Asciidoctor::Converter::CompositeConverter
    register_for 'bespoke'

    def initialize backend, opts = {}
      template_dirs = [(::File.expand_path '../../../templates', __FILE__)]
      if (extra_template_dirs = opts[:template_dirs])
        template_dirs.concat extra_template_dirs
      end
      engine_opts = (opts[:template_engine_options] || {}).dup
      engine_opts[:slim] = (engine_opts.key? :slim) ? { pretty: true }.merge(engine_opts[:slim]) : { pretty: true }
      template_opts = opts.merge htmlsyntax: 'html', template_engine: 'slim', template_engine_options: engine_opts
      template_delegate = ::Asciidoctor::Converter::TemplateConverter.new backend, template_dirs, template_opts
      html5_delegate = ::Asciidoctor::Converter::Html5Converter.new backend, opts
      super backend, template_delegate, html5_delegate
      basebackend 'html'
      htmlsyntax 'html'
    end

    def convert node, transform = nil, opts = {}
      (node.attributes.delete 'skip-option') ? '' : super
    end
  end
end
end

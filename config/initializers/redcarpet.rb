module ActionView
  module Template::Handlers
    # Rails template handler for Markdown
    class Markdown
      class_attribute :default_format
      self.default_format = Mime::HTML

      # @param template [ActionView::Template]
      # @return [String] Ruby code that when evaluated will return the rendered
      #   content
      def call(template)
        @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                              autolink:             true,
                                              fenced_code_blocks:   true,
                                              highlight:            true,
                                              no_intra_emphasis:    true,
                                              space_after_headers:  true,
                                              tables:               true,
                                              underline:            true)
        "#{@markdown.render(template.source).inspect}.html_safe"
      end
    end
  end
end

ActionView::Template.register_template_handler(
  :md, ActionView::Template::Handlers::Markdown.new)
class ActiveAdmin::Views::Pages::Base < Arbre::HTML::Document

  private

  # Renders the content for the footer
  def build_footer
    div :id => "footer" do
      revision = Smartkiosk::Server.revision.blank? ? '' : "(#{Smartkiosk::Server.revision})"
      para "Smartkiosk #{Smartkiosk::Server::VERSION} #{revision} &copy; 2012 &mdash; #{Date.today.year}".html_safe
    end
  end

end
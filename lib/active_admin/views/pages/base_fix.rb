class ActiveAdmin::Views::Pages::Base < Arbre::HTML::Document

  private

  # Renders the content for the footer
  def build_footer
    div :id => "footer" do
      para "<a href='http://roundlake.ru'>Round Lake</a>: Smartkiosk &copy;".html_safe
    end
  end

end
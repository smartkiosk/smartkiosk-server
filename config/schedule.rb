require ::File.expand_path('../environment',  __FILE__)

require 'clockwork'
include Clockwork

every(1.day, 'revisions.assign', :at => '02:00') do
  date = Date.today
  list = ::Gateway.all.map{|x| x.librarize}.select{|x| x.requires_revision?}

  list.each do |x|
    Revision.create!(:gateway_id => x.gateway.id, :date => date)
  end
end
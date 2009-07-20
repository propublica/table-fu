ActionController::Routing::Routes.draw do |map|
  map.connect ':slug/:page', :controller => 'yavin', :action => 'view', :requirements => { :page => /\d+/}, :page => nil
  map.connect ':slug/expire', :controller => 'yavin', :action => 'expire'
end

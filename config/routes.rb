SpacialdbRouting::Application.routes.draw do
  root :to => "map#index"
  match 'map/route' => 'map#route', :defaults => { :format => :json }
end

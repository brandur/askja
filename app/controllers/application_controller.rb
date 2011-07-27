class ApplicationController < ActionController::Base
  protect_from_forgery

  def expire_page_all_formats(url)
    expire_page(url)
    expire_page(url + '.atom')
    expire_page(url + '.json')
    expire_page(url + '.xml')
  end
end

class Admin::BeeEditorsController < ApplicationController
  # Possible values for bee_template_url:
  #
  # one-column
  # promo
  # newsletter
  # m-bee
  # base-one-column
  # base-m-bee
  # base-newsletter
  # base-promo
  layout 'admin'

  def index
    @template_url = bee_templates_url('m-bee')
  end

  def token
    uri = URI('https://auth.getbee.io/apiauth')
    res = Net::HTTP.post_form(
      uri,
      grant_type: 'password',
      client_id: '4ed5ef91-b85b-483c-b5ec-bd81a849a909',
      client_secret: 'uSupAtPITt1X1thC93lcY1T4SFTM21ozoQXviPDV55t2QSYpbpd'
    )
    render json: res.body
  end

  private

  def bee_templates_url(id)
    return "https://rsrc.getbee.io/api/templates/#{id}"
  end

  
end

require 'stripe'

class ChargesController < ApplicationController

  def create
 # Creates a Stripe Customer object, for associating with the charge
   customer = Stripe::Customer.create(
     email: current_user.email,
     card: params[:stripeToken]
   )

   charge = Stripe::Charge.create(
     customer: customer.id, #not same as user_id
     amount: Amount.default,
     description: "Premium Membership - #{current_user.email}",
     currency: 'usd'
   )
   current_user.update_attribute(:role, 'premium')
   flash[:notice] = "Thanks for all the money, #{current_user.email}! Your account has been upgraded to Premium."
   redirect_to wikis_path

   # Stripe will send back CardErrors. This `rescue block` catches and displays those errors.
    rescue Stripe::CardError => e
      flash[:alert] = e.message
      redirect_to new_charge_path
  end

  def new
    @stripe_btn_data = {
      key: ENV["PUBLISHABLE_KEY"],
      description: "Premium Membership - #{current_user.email}",
      amount: Amount.default
    }
  end


end
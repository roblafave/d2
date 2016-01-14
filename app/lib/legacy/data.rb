module Legacy
  class Data
    def self.load!
      Rails.logger.info "== Importing legacy Users =================================="

      usa = Spree::Country.find_by(iso: 'US') || Spree::Country.first
      states = { # need string hash keys, thus => syntax
        "CA" => Spree::State.find_by(abbr: 'CA', country: usa),
        "NV" => Spree::State.find_by(abbr: 'NV', country: usa),
      }
      stripe_payment_method = Spree::PaymentMethod.find_by(type: "Spree::Gateway::StripeGateway")

      users_imported = 0
      addresses_imported = 0
      stripe_ids_imported = 0
      Legacy::User.find_each do |user|
        Rails.logger.info "-- importing user: #{user.id} #{user.email}"
        spree_user = Spree::User.find_or_create_by(email: user.email) do |spree_user|
          spree_user.login = user.email
          spree_user.last_sign_in_ip = user.creation_ip
          spree_user.created_at = user.created
          spree_user.updated_at = user.last_updated
          spree_user.password = SecureRandom.hex(12) # imported users must set a new password
        end

        if spree_user.persisted?
          users_imported += 1
        else
          Rails.logger.info "-- user errors: #{spree_user.errors.messages}"
          next unless spree_user.errors[:email] = ["has already been taken"] # skip to next user unless we are re-importing
        end

        # skip to next user if we already imported an address
        next if Spree::UserAddress.unscoped.where(user_id: spree_user.id).any?

        state = states[user.state]
        address_attributes = {
          firstname: user.first_name,
          lastname: user.last_name,
          address1: user.address,
          address2: user.apt_suite,
          city: user.city,
          state: state,
          country: usa,
          zipcode: user.zip,
          phone: user.phone,
        }
        full_attributes = Spree::Address.value_attributes(
          Spree::Address.column_defaults,
          Spree::Address.new(address_attributes).attributes
        )
        new_address = Spree::Address.new(full_attributes)
        user_address = spree_user.user_addresses.build
        user_address.archived = false
        user_address.default = true
        user_address.address = new_address

        if new_address.valid? && user_address.save(validate: false)
          addresses_imported += 1
        else
          Rails.logger.info "  -> address errors: #{new_address.errors.messages}" if new_address.errors.present?
        end

        if user.stripe_id.present?
          spree_credit_card = spree_user.credit_cards.build({
            gateway_customer_profile_id: user.stripe_id,
            cc_type: user.card_type,
            last_digits: user.last4,
            name: "#{new_address.firstname} #{new_address.lastname}",
            default: true,
            payment_method: stripe_payment_method,
            address_id: new_address.id,
          })
          if spree_credit_card.save
            stripe_ids_imported += 1
          else
            Rails.logger.info "  -> credit card errors: #{spree_credit_card.errors.messages}" if spree_credit_card.errors.present?
          end
        end
      end

      Rails.logger.info "== Imported: ==============================================="
      Rails.logger.info ["#{users_imported} users", "#{addresses_imported} addresses", "#{stripe_ids_imported} Stripe IDs"]
    end
  end
end

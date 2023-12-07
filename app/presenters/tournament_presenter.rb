class TournamentPresenter
	include ActionView::Helpers::DateHelper
	include Rails.application.routes.url_helpers

	def initialize(tournament:, current_user:)
		@tournament = tournament
		@current_user = current_user
	end

	attr_reader :tournament, :current_user

	delegate :user, :name, :status, :description, :registrations_count, :max_lvl1, :max_lvl2, :max_lvl5, :max_lvl4, :registration_count, to: :tournament
	delegate :display_name, :username, :avatar, :image_profile, to: :user

	def created_at
		if (Time.zone.now - tournament.created_at) > 1.day
			tournament.created_at.strftime("%b %-d")
		else
			time_ago_in_words(tournament.created_at)
		end
	end

	def registration_tournament_url
		if tournament_registrated_by_current_user?
			tournament_registration_path(tournament, current_user.registrations.find_by(tournament: tournament))
		else
			tournament_registrations_path(tournament)
		end
	end

	def size_registration
		if tournament_registrated_by_current_user?
			"15x15"
		else
			"19x19"
		end
	end

	def turbo_data_registration_method
		if tournament_registrated_by_current_user?
			"delete"
		else
			"post"
		end
	end

	def registration_heart_image
		if tournament_registrated_by_current_user?
			"tennis_filled.png"
		else
			"tennis-ball.png"
		end
	end

  def created_at
		if (Time.zone.now - tournament.created_at) > 1.day
			tournament.created_at.strftime("%b %-d")
		else
			time_ago_in_words(tournament.created_at)
		end
	end

	private

	def tournament_registrated_by_current_user
		@tournament_registrated_by_current_user ||= tournament.registrated_users.include?(current_user)
	end

	alias_method :tournament_registrated_by_current_user?, :tournament_registrated_by_current_user
end

class RiskConfiguration < ActiveRecord::Base
	has_many :risk_levels
	has_many :risk_probabilities
	has_many :risk_consequences
	has_many :impacts
	has_paper_trail
end

require 'cfn-nag/violation'
require_relative 'base'

class SecurityGroupEgressPortRangeRule < BaseRule
  def rule_text
    'Security Groups found egress with port range instead of just a single port'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W29'
  end

  ##
  # This will behave slightly different than the legacy jq based rule which was targeted against inline ingress only
  def audit_impl(cfn_model)
    logical_resource_ids = []
    cfn_model.security_groups.each do |security_group|
      violating_egresses = security_group.egresses.select do |egress|
        egress.fromPort != egress.toPort
      end

      unless violating_egresses.empty?
        logical_resource_ids << security_group.logical_resource_id
      end
    end

    violating_egresses = cfn_model.standalone_egress.select do |standalone_egress|
      standalone_egress.fromPort != standalone_egress.toPort
    end

    logical_resource_ids + violating_egresses.map(&:logical_resource_id)
  end
end

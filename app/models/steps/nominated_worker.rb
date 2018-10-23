module Steps
  class NominatedWorker < JourneyStep
    attribute :nominated_worker
    validates :nominated_worker, inclusion: { in: %w[yes no] }

    def next_step_class
      case nominated_worker
      when 'yes'
        SchoolPostcode
      when 'no'
        SchoolPayroll
      end
    end
  end
end
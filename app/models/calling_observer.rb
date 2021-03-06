class CallingObserver < ActiveRecord::Observer

  def after_create(calling)
    calling.user.check_badge_condition_on('realtime_callings_count')
  end
  
end

class CallingsController < ApplicationController
  respond_to :html
  before_filter :login_required, :except => [:index, :show]
  before_filter :find_calling, :except => [:index, :new, :create]
  after_filter  :clean_unread, :only => [:show]
   
  def index
    @callings = Calling.all
  end

  def new
    @calling = current_user.callings.build(:venue_id => params[:venue_id],:action_id => params[:action_id],:unit => '件')
    if @calling.action.nil?
      @actions = Action.all
      @venue = Venue.find(params[:venue_id])
      render :select_action, :layout =>  !(params[:layout] == 'false')
    end
  end
  
  def create
    @calling = current_user.callings.build(params[:calling])
    if @calling.save
      flash[:dialog] = "<a href='#{new_sync_path}?syncable_type=#{@calling.class}&syncable_id=#{@calling.id}' class='open_dialog' title='传播这个行动'>同步</a>" 
    end
    respond_with @calling
  end

  def show
    @calling = Calling.find(params[:id])
    @venue = @calling.venue
    @action = @calling.action
    @plans = @calling.plans.undone
    @records = @calling.records
    @my_plan = @plans.select{|p| p.user_id == current_user.id}.first if logged_in? # user`s plan on this calling
    @my_record = @records.select{|r| r.user_id == current_user.id}.first if logged_in? # user`s record on this calling
    @followers = @calling.followers
    @comment = Comment.new
    @comments = @calling.comments
    @photos = @calling.photos.limit(3)
    render :layout => "no_sidebar"
  end
  
  def edit
  end
  
  def update
    @calling.update_attributes(params[:calling])
    if params[:back_path].present?
      redirect_to params[:back_path]
    else
      respond_with @calling
    end
  end

  def destroy
    #@calling.destroy
    #if params[:back_path].present?
    #  redirect_to params[:back_path]
    #else
    #  respond_with @calling
    #end
  end
  
  def close
    @calling.update_attributes(:close => true) if @calling.user == current_user
    respond_with @calling
  end
  
  private
  def find_calling
    @calling = Calling.find(params[:id])
  end
  
  def clean_unread
    @calling.update_attribute(:has_new_comment,false) if @calling.user == current_user && @calling.has_new_comment
    @calling.update_attribute(:has_new_plan,false) if @calling.user == current_user && @calling.has_new_plan
    @calling.follows.where(:user_id => current_user.id).first.update_attribute(:has_new_comment,false) if current_user && @calling.follows.where(:user_id => current_user.id).present?
    @calling.comments.where(:user_id => current_user.id).map{|a| a.update_attribute(:has_new_comment,false)} if logged_in? == @calling.comments.where(:user_id => current_user.id).first.present?
  end
  
end

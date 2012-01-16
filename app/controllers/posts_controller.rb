class PostsController < ApplicationController
  before_filter :check_user, :only => [:new, :update, :edit, :destroy]

  # GET /posts
  # GET /posts.xml
  def index
    if params[:all]
      @posts = Post.all
    elsif
      @posts = Post.tagged_with("blog")
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  def pictures
    FlickRaw.api_key="cca4e5c768a106ef85d2a19e22f8222d"
    FlickRaw.shared_secret="8a7e63e250a887fe"
    #info = flickr.photos.getInfo(:photo_id => "5752508461")
    #url = FlickRaw.url_photostream(info) # => "http://www.flickr.com/photos/41650587@N02/"
    #logger.info(url)
    username = "dds1024"
    user = flickr.people.findByUsername( :username => username )
    begin
      @photo_list = flickr.people.getPublicPhotos( :user_id => user.nsid, :per_page => 12, :extras => 'description' )

      @photo_list.each do |p|
        sizes = flickr.photos.getSizes :photo_id => p.id
        #logger.info(sizes.inspect)
        #original = sizes.find {|s| s.label == 'Original' }
        #original.width       # => "800"
        #logger.info(p.inspect)
      end
    rescue
      @photo_list = []
      flash[:notice]="Something happend with Flickr's API, try refreshing to fix."
      #logger.info(@photo_list)
      #@posts = Post.tagged_with("me")
    end
      respond_to do |format|
        format.html
      end
    end

  def me
    @posts = Post.tagged_with("me")
    respond_to do |format|
      format.html
    end
  end

  def work
    @posts = Post.tagged_with("work")
    respond_to do |format|
      format.html
    end
  end

  def twitter
    respond_to do |format|
      format.html
    end
  end

  def paleo
    Twitter.configure do |config|
      config.consumer_key = 'WOBXTuBXu94Z8gnJ2lw'
      config.consumer_secret = 'm0zk3JSuVGeMqhfAKh9FTS11VsYkZ5vinHWuJJCfo'
      config.oauth_token = '448955415-krkAltBKcSB7oSZorfDGN7oautktopEQmlxMJzXj'
      config.oauth_token_secret = '4pLdwBKyvgVwNmF4hF1b4oQrYODohdIFuBB3rweg'
    end
    #@tweets = Twitter.search("to:paleofoodfight", :rpp => 100, :include_entities => true)
    if params[:count]
      @tweets = Twitter.mentions(:count => params[:count])
    else
      @tweets = Twitter.mentions(:count => 20)
    end
    @pics = []
    @tweets.each do |tweet, k|
      t = Twitter.status(tweet.id, :include_entities => true)
      if t.attrs['entities']['media']
        image_url = t.attrs['entities']['media'][0]['media_url']
      elsif t.attrs['entities']['urls'] and not t.attrs['entities']['urls'].empty?
        image_url = t.attrs['entities']['urls'][0]['expanded_url'] + ':iphone'
      else
        next
      end
      
      if image_url
        text = tweet.text.sub('@PaleoFoodFight', '')
        regex = Regexp.new '((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)'
        text = text.gsub( regex, '' )
        @pics << { :image_url => image_url, :text => text, :user => tweet.attrs['user']['name']}
      end
      image_url = nil
       
    end
    if not params[:blog]
      render :template => 'posts/paleo_squares.html.erb'
    else
      respond_to do |format|
        format.html
      end
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/1/edit
  def edit
      @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])
    @post.tag_list = params[:tags]

    respond_to do |format|
      if @post.save
        format.html { redirect_to(@post, :notice => 'Post was successfully created.') }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])
    @post.tag_list = params[:tags]
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to(@post, :notice => 'Post was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end

  private 

    def check_user
      if !current_user
        flash[:error] = "Sorry, you don't have permission to manage posts!"
        redirect_to(root_url)                                                    
      end
    end

end

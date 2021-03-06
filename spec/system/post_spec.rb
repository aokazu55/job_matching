require 'rails_helper'

RSpec.describe 'Post Test', type: :system, js: true do
  before do
    @user = User.create(email: 'user@sample.com', password: "password", password_confirmation: "password")
    @user1 = User.create(email: 'user1@sample.com', password: "password", password_confirmation: "password")
    @company = Company.create!(name: "sample_company", :email => 'test@example.com', :password => 'f4k3p455w0rd')
    @post = FactoryBot.create(:post, company_id: @company.id)
    @company1 = Company.create(email: 'company1@sample.com', password: "password", password_confirmation: "password")
    @post1 = FactoryBot.create(:post, company_id: @company1.id)
    JobCategory.create(name: "test_category")
    Industry.create(name: "test_industry")
  end

  describe 'カンパニーの権限' do
    before do
      login_as(@company, :scope => :company)
      @company.company_skills.create(name: "test_skill")
    end

    it '自社のダッシュボードページからPost作成画面にアクセスできること' do
      visit dashboard_company_path(@company.id)
      click_on 'Create New Post'
      expect(page).to have_current_path new_post_path
    end

    it 'Postを作成できる' do
      visit new_post_path
      fill_in 'Title', with:'wei'
      fill_in 'Salary', with:'222'
      fill_in 'Number of recruits', with:'2'
      fill_in 'Position', with:'Head'
      fill_in 'Description', with:'aaa aaa iii'
      fill_in 'Location', with:'yangon'

      select 'test_skill', from: "post_post_skills_attributes_0_company_skill_id"
      select 'test_category', from: "post_post_job_categories_attributes_0_job_category_id"
      select 'test_industry', from: "post_post_industries_attributes_0_industry_id"

      click_on 'Create Post'

      expect(page).to have_content "wei"
      expect(page).to have_content "yangon"
      expect(page).to have_content "successfully"
    end

    it '自社のポストページにアクセスできる' do
      visit post_path(@post.id)
      expect(page).to have_current_path post_path(@post.id)
    end

    it '他社のポストページにアクセスできる' do
      visit post_path(@post1.id)
      expect(page).to have_current_path post_path(@post1.id)
      expect(page).not_to have_content 'Like'
      expect(page).not_to have_content 'Unlike'
      expect(page).not_to have_content 'Apply Now'
      expect(page).not_to have_content 'Delete Application'
    end

    it 'Postを編集できる' do
      visit edit_post_path(@post.id)
      fill_in 'Title', with:'wei'
      click_on 'Update Post'

      expect(page).to have_content "wei"
      expect(page).to have_content "successfully"
    end

    it '他社のPost編集ページにアクセスできない' do
      visit edit_post_path(@post1.id)
      expect(page).to have_content "No Access Right."
      expect(page).to have_current_path root_path
    end

    it 'Postを削除できる' do
      x = @company.posts.count
      visit dashboard_company_path(@company.id)

      accept_alert do
        click_link 'delete'
      end
      sleep 1
      y = @company.posts.count
      expect(x-y).to eq 1
    end

    it 'Postのマネージページにアクセスできる' do
      visit manage_post_path(@post.id)
      expect(page).to have_current_path manage_post_path(@post.id)
    end

    it '他社のPostのマネージページにアクセスできない' do
      visit manage_post_path(@post1.id)
      expect(page).to have_content "No Access Right."
      expect(page).to have_current_path root_path
    end
  end

  describe 'ログインユーザーの権限' do
    before do
      login_as(@user, :scope => :user)
    end

    it 'ポスト作成ページにアクセスできないこと' do
      visit new_post_path
      expect(page).to have_current_path new_company_session_path
    end

    it 'ポストページにアクセスできる' do
      visit post_path(@post1.id)
      expect(page).to have_current_path post_path(@post1.id)
      expect(page).to have_content 'Like'
      expect(page).to have_content 'Apply Now'
    end

    it 'Post編集ページにアクセスできない' do
      visit edit_post_path(@post1.id)
      expect(page).to have_current_path new_company_session_path
    end

    it 'Postのマネージページにアクセスできない' do
      visit manage_post_path(@post1.id)

      expect(page).to have_current_path new_company_session_path
    end
  end

  describe '未ログインユーザーの権限' do
    it 'ポスト作成ページにアクセスできないこと' do
      visit new_post_path
      expect(page).to have_current_path new_company_session_path
    end

    it 'ポストページにアクセスできる' do
      visit post_path(@post1.id)
      expect(page).to have_current_path post_path(@post1.id)
      expect(page).not_to have_content 'Like'
      expect(page).not_to have_content 'Apply Now'
    end

    it 'Post編集ページにアクセスできない' do
      visit edit_post_path(@post1.id)
      expect(page).to have_current_path new_company_session_path
    end

    it 'Postのマネージページにアクセスできない' do
      visit manage_post_path(@post1.id)

      expect(page).to have_current_path new_company_session_path
    end
  end
end

require 'spec_helper'

# тесты для страницы со списком пользователей.
describe "User pages" do

  subject { page }

  describe "index" do
    before do
      sign_in FactoryGirl.create(:user)
      FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
      FactoryGirl.create(:user, name: "Ben", email: "ben@example.com")
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    it "should list each user" do
      User.all.each do |user|
        expect(page).to have_selector('li', text: user.name)
      end
    end
  end

  describe "Static pages" do

    subject { page }

    describe "Home page" do
      before { visit root_path }

      it { should have_content('Sample App') }
      it { should have_title(full_title('')) }
      it { should_not have_title('| Home') }

      # Тест рендеринга потока сообщений на странице Home.
      describe "for signed-in users" do
        let(:user) { FactoryGirl.create(:user) }
        before do
          FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
          FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
          sign_in user
          visit root_path
        end

        it "should render the user's feed" do
          user.feed.each do |item|
            expect(page).to have_selector("li##{item.id}", text: item.content)
          end
        end
      end

      # Тестирование статистики читатели/читаемые
      describe "for signed-in users" do
        let(:user) { FactoryGirl.create(:user) }
        before do
          FactoryGirl.create(:micropost, user: user, content: "Lorem")
          FactoryGirl.create(:micropost, user: user, content: "Ipsum")
          sign_in user
          visit root_path
        end

        it "should render the user's feed" do
          user.feed.each do |item|
            expect(page).to have_selector("li##{item.id}", text: item.content)
          end
        end

        describe "follower/following counts" do
          let(:other_user) { FactoryGirl.create(:user) }
          before do
            other_user.follow!(user)
            visit root_path
          end

          it { should have_link("0 following", href: following_user_path(user)) }
          it { should have_link("1 followers", href: followers_user_path(user)) }
        end
      end
    end

    describe "Help page" do
      before { visit help_path }

      it { should have_content('Help') }
      it { should have_title(full_title('Help')) }
    end

    describe "About page" do
      before { visit about_path }

      it { should have_content('About') }
      it { should have_title(full_title('About Us')) }
    end

    describe "Contact page" do
      before { visit contact_path }

      it { should have_content('Contact') }
      it { should have_title(full_title('Contact')) }
    end
  end
end
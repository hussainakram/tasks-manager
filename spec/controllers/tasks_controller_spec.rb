# frozen_string_literal: true
require "rails_helper"

RSpec.describe(TasksController) do
  let!(:user) { create(:user) }

  describe "GET /tasks" do
    let!(:tasks) { create_list(:task, 5, user: user) }

    it "DO not render the index template for unsigned in user" do
      get :index

      expect(response).to(have_http_status(302))
    end

    it "Do not render the index template for unconfirmed signed in user" do
      sign_in(user)

      get :index

      expect(response).to(have_http_status(302))
    end

    it "renders the index template for confirmed signed in user" do
      signin_as_confirmed_user

      get :index

      expect(response).to(have_http_status(:ok))
      expect(response).to(render_template(:index))
      expect(assigns(:tasks)).to(eq(tasks))
    end
  end

  describe "POST /tasks" do
    context "do not create with bad data" do
      it "title as nil" do
        signin_as_confirmed_user

        task_params = build(:task, title: nil).attributes

        expect { post(:create, params: { task: task_params }) }.to(change(Task, :count).by(0))
        expect(response).to(have_http_status(:unprocessable_entity))
      end

      it "status as nil" do
        signin_as_confirmed_user

        task_params = build(:task, status: nil).attributes

        expect { post(:create, params: { task: task_params }) }.to(change(Task, :count).by(0))
        expect(response).to(have_http_status(:unprocessable_entity))
      end

      it "user as nil" do
        signin_as_confirmed_user

        task_params = build(:task, user: nil).attributes

        expect { post(:create, params: { task: task_params }) }.to(change(Task, :count).by(0))
        expect(response).to(have_http_status(:unprocessable_entity))
      end
    end

    context "create a task" do
      it "with good data" do
        signin_as_confirmed_user

        task_params = build(:task, user: user).attributes

        expect(response).to(have_http_status(:ok))
        expect { post(:create, params: { task: task_params }) }.to(change(Task, :count).by(1))
      end
    end
  end

  describe "GET /task/:id" do
    it "do not show task of another user" do
      signin_as_confirmed_user

      second_user = create(:user)
      task = create(:task, user: second_user)
      get :show, params: { id: task.id }

      expect(response).to(have_http_status(302))
      expect(response).to_not(render_template(:show))
    end

    it "do not show task to unsigned user" do
      task = create(:task, user: user)
      get :show, params: { id: task.id }

      expect(response).to(have_http_status(302))
      expect(response).to_not(render_template(:show))
    end

    it "show user its own task" do
      signin_as_confirmed_user

      task = create(:task, user: user)
      get :show, params: { id: task.id }

      expect(response).to(render_template(:show))
    end
  end

  describe "PUT /tasks" do
    context "with bad data" do
      it "title as nil" do
        signin_as_confirmed_user

        task = create(:task)

        put :update, params: { id: task, task: task.attributes.merge(title: nil) }

        expect(response).to(have_http_status(302))
      end

      it "status as nil" do
        signin_as_confirmed_user

        task = create(:task)

        put :update, params: { id: task, task: task.attributes.merge(status: nil) }

        expect(response).to(have_http_status(302))
      end

      it "user as nil" do
        signin_as_confirmed_user

        task = create(:task)

        put :update, params: { id: task, task: task.attributes.merge(user_id: nil) }

        expect(response).to(have_http_status(302))
      end
    end

    context "with good data" do
      it "updates the task and redirects" do
        signin_as_confirmed_user

        task = create(:task, user: user)

        put :update, params: { id: task, task: task.attributes.merge(title: "test123", status: 2) }

        expect(task.reload.title).to(eq("test123"))
        expect(task.reload.status).to(eq(2))
        expect(response).to(be_redirect)
      end
    end
  end

  describe "DELETE /tasks" do
    it "do not delete task of another user" do
      signin_as_confirmed_user

      second_user = create(:user)
      task = create(:task, user: second_user)
      delete :destroy, params: { id: task.id }

      expect(response).to(have_http_status(302))
    end

    it "do not delete with invalid id" do
      signin_as_confirmed_user

      second_user = create(:user)
      task = create(:task, user: second_user)
      delete :destroy, params: { id: 'xx' }

      expect(response).to(have_http_status(302))
    end

    it "do not delete with invalid id" do
      signin_as_confirmed_user

      second_user = create(:user)
      task = create(:task, user: second_user)
      delete :destroy, params: { id: 'xx' }

      expect(response).to(have_http_status(302))
    end
  end

  private

  def signin_as_confirmed_user
    user.confirm
    sign_in(user)
  end
end

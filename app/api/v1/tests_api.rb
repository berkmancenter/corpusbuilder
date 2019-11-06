class V1::TestsAPI < Grape::API
  include V1Base

  resources :tests do
    post 'clean' do
      App.delete_all
      Document.delete_all
      Editor.delete_all
      Surface.delete_all
      Image.delete_all
      Grapheme.delete_all

      Revision.all.each do |rev|
        Revision.connection.execute "drop table if exists graphemes_revisions_#{rev.id.gsub(/-/, '_')}"
      end

      Revision.delete_all
      Branch.delete_all
      Zone.delete_all
    end

    post 'prepare' do
      Shared::Seed.run!
    end
  end
end

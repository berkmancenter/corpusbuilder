require 'rails_helper'

RSpec.describe Pipeline::Local, type: :model do

  let(:client_app) do
    create :app
  end

  let(:document) do
    create :document, status: Document.statuses[:processing], app_id: client_app.id
  end

  context "the forward method" do

    shared_examples "preprocessing step" do
      let(:pipeline) do
        create :local_pipeline, document_id: document.id, data: { "stage" => stage },
          status: Pipeline.statuses[:processing]
      end

      context "when the step raises exception" do
        it "keeps the stage at the same level" do
          allow_any_instance_of(Pipeline::Local).to receive(step).and_raise(StandardError)
          pipeline.forward
          expect(pipeline.reload.stage).to eq(stage)
        end
      end

      context "when the step returns :more indicating more work to be done" do
        it "keeps the stage at the same level" do
          allow_any_instance_of(Pipeline::Local).to receive(step).and_return(:more)
          pipeline.forward
          expect(pipeline.reload.stage).to eq(stage)
        end
      end

      context "when the step returns :done indicating no more work to be done" do
        it "moves the stage to the next level" do
          expect_any_instance_of(Pipeline::Local).to receive(step).and_return(:done)
          pipeline.forward
          expect(pipeline.reload.stage).to eq(next_stage)
        end
      end
    end

    context "the preprocess stage" do
      it_behaves_like "preprocessing step"

      let(:stage) { "preprocess" }
      let(:step) { :preprocess }
      let(:next_stage) { "segment" }

      let(:image1) { instance_double("Image", :preprocessed? => true) }
      let(:image2) { instance_double("Image", :preprocessed? => false) }
      let(:image3) { instance_double("Image", :preprocessed? => false) }
      let(:images) { [ image1, image2, image3 ] }

      let(:pipeline) do
        create :local_pipeline, document_id: document.id, data: { "stage" => "preprocess" },
          status: Pipeline.statuses[:processing]
      end

      it "calls Images::Preprocess for the first image not preprocessed yet" do
        expect_any_instance_of(Document).to receive(:images).and_return(images)
        expect(Images::Preprocess).to receive(:run!).with(image: image2)

        pipeline.forward
      end

      it "returns :done when all images have been preprocessed already" do
        expect_any_instance_of(Document).to receive(:images).and_return(
          [
            instance_double("Image", :preprocessed? => true),
            instance_double("Image", :preprocessed? => true)
          ]
        )

        expect(pipeline.preprocess).to eq(:done)
      end
    end

    context "the segment stage" do
      it_behaves_like "preprocessing step"

      let(:stage) { "segment" }
      let(:step) { :segment }
      let(:next_stage) { "ocr" }
    end

    context "the ocr stage" do
      it_behaves_like "preprocessing step"

      let(:stage) { "ocr" }
      let(:step) { :ocr }
      let(:next_stage) { "done" }

      let(:image1) { instance_double("Image", :ocred? => true) }
      let(:image2) { instance_double("Image", :ocred? => false) }
      let(:image3) { instance_double("Image", :ocred? => false) }
      let(:images) { [ image1, image2, image3 ] }

      let(:pipeline) do
        create :local_pipeline, document_id: document.id, data: { "stage" => "ocr" },
          status: Pipeline.statuses[:processing]
      end

      it "calls Images::OCR for the first image not ocred yet" do
        expect_any_instance_of(Document).to receive(:images).and_return(images)
        expect(Images::OCR).to receive(:run!).with(image: image2, backend: :tesseract)

        pipeline.forward
      end
    end

  end

end

module Revisions
  class Visualize < Action::Base
    attr_accessor :document, :format, :file_name

    def execute
      revision_nodes
      revision_edges

      graph.output(format => file_name)
    end

    def graph
      memoized do
        GraphViz.new(:G, :type => :digraph)
      end
    end

    def revision_nodes
      memoized do
        grouped_revisions.inject({}) do |state, group|
          id, revision = group
          revision = revision.first

          state[id] = graph.add_nodes(
            revision_label(revision)
          )

          state
        end
      end
    end

    def revision_edges
      memoized do
        revision_nodes.each do |id, node|
          revision = grouped_revisions[ id ].try(:first)
          parent = revision_nodes[ revision.parent_id ]
          merged_with = revision_nodes[ revision.merged_with_id ]

          if parent.present?
            graph.add_edges(parent, node)
          end

          if merged_with.present?
            graph.add_edges(merged_with, node, style: "dashed")
          end
        end
      end
    end

    def grouped_revisions
      memoized do
        Revision.where(document_id: document.id).
          group_by(&:id)
      end
    end

    def grouped_branches
      memoized do
        Branch.joins(:revision).
          where(revisions: { document_id: document.id }).
          group_by(&:revision_id)
      end
    end

    def revision_label(revision)
      branch = grouped_branches[ revision.id ].try(:first)

      "#{revision.id}\n#{revision.status}#{ branch.present? ? "\n(#{branch.name})" : '' }"
    end
  end
end

# frozen_string_literal: true

module Git
  # Class which holds whole collection of raw methods to work with git
  class Lib
    # `git merge-base ...`. Returns common ancestor for all passed commits
    #
    # @param [Array<Object>] args - list of commits to process. Last argument can be options for merge-base command
    # @return [String]
    def merge_base(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      arg_opts = opts.filter_map { |k, v| "--#{k}" if v } + args

      command("merge-base", *arg_opts.flatten)
    end
  end
end

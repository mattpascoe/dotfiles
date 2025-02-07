return {
  {
    'rmagatti/auto-session',
    lazy_support = true,

    init = function()
      -- Add localoptions as per auto-session plugin suggestion
      vim.opt.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
    end,
    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { '~/', '~/Downloads', '/' },
      args_allow_files_auto_save = true,
      log_level = 'error',
    },
  },
}

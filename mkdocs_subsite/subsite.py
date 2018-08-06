# -*- flycheck-python-pylint-executable: "pylint" -*-
# pylint: disable=invalid-name, missing-docstring, too-few-public-methods

from __future__ import division, print_function
import os.path

from mkdocs.structure.files import _sort_files, _filter_paths, File
from mkdocs.structure.nav import Section
from mkdocs.plugins import BasePlugin
from mkdocs.config import config_options
import yaml

class SubsitePlugin(BasePlugin):
    config_scheme = (('sites', config_options.Type(list)),)

    def on_config(self, config):
        for site in self.config['sites']:
            mountpoint, key = config, 'nav' if 'nav' in config else 'pages'
            for part in site['nav_path'].split('/'):
                mountpoint_old = mountpoint
                for item in mountpoint[key]:
                    new = item.keys()[0]
                    if part == new:
                        mountpoint, key = item, new
                        break
                if mountpoint == mountpoint_old:
                    raise ValueError('Navigation item "%s" not found ("%s")'
                                     % (part, site['nav_path']))
            with open(os.path.join(site['base_path'], 'mkdocs.yml')) as f:
                cfg = yaml.load(f)
            sub_base = os.path.relpath(os.path.abspath(site['base_path']), config['docs_dir'])
            sub_docs = cfg.get('docs_dir', 'docs')
            def relativize(x):
                for k, v in x.items():
                    if isinstance(v, list):
                        for vv in v:
                            relativize(vv)
                    else:
                        x[k] = os.path.join(sub_base, sub_docs, v) #pylint: disable=cell-var-from-loop
            sub = {'': cfg.get('nav', None) or cfg['pages']}
            relativize(sub)
            mountpoint[new] += sub['']
        return config

    def on_files(self, files, config):
        for site in self.config['sites']:
            (_files, src_paths) = get_files(os.path.join(site['base_path'], 'docs'), config)
            files._files += _files
            files.src_paths.update(src_paths)
        return files

def get_files(base_dir, config):
    files = []
    exclude = ['.*', '/templates']

    for source_dir, dirnames, filenames in os.walk(base_dir, followlinks=True):
        relative_dir = os.path.relpath(source_dir, config['docs_dir'])

        for dirname in list(dirnames):
            path = os.path.normpath(os.path.join(relative_dir, dirname))
            # Skip any excluded directories
            if _filter_paths(basename=dirname, path=path, is_dir=True, exclude=exclude):
                dirnames.remove(dirname)
        dirnames.sort()

        for filename in _sort_files(filenames):
            path = os.path.normpath(os.path.join(relative_dir, filename))
            # Skip any excluded files
            if _filter_paths(basename=filename, path=path, is_dir=False, exclude=exclude):
                continue
            f = File(path, config['docs_dir'], config['site_dir'], config['use_directory_urls'])
            f.dest_path = f.dest_path.replace(relative_dir + '/', '')
            f.abs_dest_path = os.path.normpath(os.path.join(config['site_dir'], f.dest_path))
            f.url = f.url.replace(relative_dir + '/', '')
            files.append(f)

    return (files, {file.src_path: file for file in files})

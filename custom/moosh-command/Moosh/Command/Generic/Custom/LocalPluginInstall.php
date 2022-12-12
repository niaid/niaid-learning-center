<?php
/**
 * moosh - Moodle Shell
 *
 * @copyright  2012 onwards Tomasz Muras
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 * @author     Kacper Golewski <k.golewski@gmail.com>
 */

namespace Moosh\Command\Generic\Custom;
use Moosh\MooshCommand;
use core_plugin_manager, progress_trace_buffer, text_progress_trace;

class LocalPluginInstall extends MooshCommand
{
  private $moodlerelease;
  private $moodleversion;

  public function __construct()
  {
    parent::__construct('installplugin', 'custom');

    $this->addArgument('plugin_name');
    $this->addArgument('plugin_version');

    $this->addOption('f|force', 'Force installation even if current Moodle version is unsupported.');
    $this->addOption('d|delete', 'If it already exists, automatically delete plugin before installing.');
  }

  private function init()
  {
    global $CFG;
    $this->moodlerelease = moodle_major_version();
    if (!is_float($this->moodlerelease)) {
      $this->moodlerelease = floatval($this->moodlerelease);
    }

    $this->moodleversion = $CFG->version;
  }

  public function execute()
  {
    global $CFG;

    require_once($CFG->libdir.'/adminlib.php');       // various admin-only functions
    require_once($CFG->libdir.'/upgradelib.php');     // general upgrade/install related functions
    require_once($CFG->libdir.'/environmentlib.php');
    require_once($CFG->dirroot.'/course/lib.php');

    $this->init();

    $pluginname     = $this->arguments[0];
    $pluginversion  = $this->arguments[1];

    // This is a container. It has to be a fresh install
    $pluginman = core_plugin_manager::instance();
    $pluginfo = $pluginman->get_plugin_info($pluginname);

    if (!is_null($pluginfo->versiondb)) {
      // it exists, murderate it
      $progress = new progress_trace_buffer(new text_progress_trace(), false);
      $pluginman->uninstall_plugin($pluginfo->component, $progress);
      $progress->finished();

      upgrade_noncore(true);
    }

    $split          = explode('_', $pluginname, 2);
    $type           = $split[0];
    $component      = $split[1];
    $tempdir        = home_dir() . '/.moosh/moodleplugins/';
    $localfile      = $tempdir . $pluginname . ".zip";

    if (!file_exists($localfile)) {
      echo "Failed to locate plugin - check files in $tempdir.\n";
      return;
    }

    $installpath = $this->get_install_path($type);
    $targetpath = $installpath . DIRECTORY_SEPARATOR . $component;

    if (file_exists($targetpath)) {
      if ($this->expandedOptions['delete']) {
        echo "Removing previously installed $pluginname from $targetpath\n";
        run_external_command("rm -rf $targetpath");
      } else {
        die("Something already exists at $targetpath - please remove it and try again, or run with the -d option.\n");
      }
    }

    run_external_command("unzip $localfile -d $installpath");
    run_external_command("chmod 777 $targetpath");

    echo "Installing\n";
    echo "\tname:    $pluginname\n";
    echo "\tversion: $pluginversion\n";
    upgrade_noncore(true);
    echo "Done\n";
  }

  /**
   * Get the relative path for a plugin given it's type
   *
   * @param string $type
   *   The plugin type (example: 'auth', 'block')
   * @param string $moodleversion
   *   The version of moodle we are running (example: '1.9', '2.9')
   * @return string
   *   The installation path relative to dirroot (example: 'auth', 'blocks',
   *   'course/format')
   */
  private function get_install_path($type)
  {
    global $CFG;

    if ($this->moodlerelease >= 2.6) {
      $types = \core_component::get_plugin_types();
    } else if ($this->moodlerelease >= 2.0) {
      $types = get_plugin_types();
    } else {
      // Moodle 1.9 does not give us a way to determine plugin
      // installation paths.
      $types = array();
    }

    if (empty($types) || !array_key_exists($type, $types)) {
      // Either the moodle version is lower than 2.0, in which case we
      // don't have a reliable way of determining the install path, or the
      // plugin is of an unknown type.
      //
      // Let's fall back to make our best guess.
      return $CFG->dirroot . '/' . $type;
    }

    return $types[$type];
  }

  public function requireHomeWriteable() {
    return true;
  }
}


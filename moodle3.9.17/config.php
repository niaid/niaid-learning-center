<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();
$CFG->maintenance_enabled = 0;
$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'nlc_localhost';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'moodle';
$CFG->dbpass    = '3ever_12:)';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

// $CFG->wwwroot   = 'https://learningcenter.niaid.nih.gov';
// $CFG->wwwroot   = '/Users/kanfw/Desktop/experiment/niaid-learning-centermoodle3.9.17';
$CFG->wwwroot   = getenv('APACHE2_WEB_ROOT');
$CFG->dataroot  = '/srv/www/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

//@ini_set('display_errors', '1');
//$CFG->debug = 32767;
//$CFG->debugdisplay = true;

require_once(dirname(__FILE__) . '/lib/setup.php');


// This should allow users to use extended characters

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!

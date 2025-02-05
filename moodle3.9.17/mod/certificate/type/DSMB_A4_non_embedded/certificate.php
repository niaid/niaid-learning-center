<?php

// This file is part of the Certificate module for Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

/**
 * A4_non_embedded certificate type
 *
 * @package    mod_certificate
 * @copyright  Mark Nelson <markn@moodle.com>
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

$pdf = new PDF($certificate->orientation, 'mm', 'A4', true, 'UTF-8', false);

$pdf->SetTitle($certificate->name);
$pdf->SetProtection(array('modify'));
$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);
$pdf->SetAutoPageBreak(false, 0);
$pdf->AddPage();

// Define variables
// Landscape
if ($certificate->orientation == 'L') {
    $x = 10;
    $y = 30;
    $sealx = 230;
    $sealy = 150;
    $sigx = 47;
    $sigy = 155;
    $custx = 47;
    $custy = 155;
    $wmarkx = 40;
    $wmarky = 31;
    $wmarkw = 212;
    $wmarkh = 148;
    $brdrx = 0;
    $brdry = 0;
    $brdrw = 297;
    $brdrh = 210;
    $codey = 175;
} else { // Portrait
    $x = 10;
    $y = 40;
    $sealx = 150;
    $sealy = 220;
    $sigx = 30;
    $sigy = 230;
    $custx = 30;
    $custy = 230;
    $wmarkx = 26;
    $wmarky = 58;
    $wmarkw = 158;
    $wmarkh = 170;
    $brdrx = 0;
    $brdry = 0;
    $brdrw = 210;
    $brdrh = 297;
    $codey = 250;
}

// Add images and lines
certificate_print_image($pdf, $certificate, CERT_IMAGE_BORDER, $brdrx, $brdry, $brdrw, $brdrh);
certificate_draw_frame($pdf, $certificate);
// Set alpha to semi-transparency
$pdf->SetAlpha(0.2);
certificate_print_image($pdf, $certificate, CERT_IMAGE_WATERMARK, $wmarkx, $wmarky, $wmarkw, $wmarkh);
$pdf->SetAlpha(1);
certificate_print_image($pdf, $certificate, CERT_IMAGE_SEAL, $sealx, $sealy, '', '');
certificate_print_image($pdf, $certificate, CERT_IMAGE_SIGNATURE, $sigx, $sigy, '', '');

//certificate_print_text($pdf, $x, $y + 65, 'L', 'Helvetica', '', 12, 'Completion Date: ');

// Add text
$pdf->SetTextColor(0, 0, 120);
certificate_print_text($pdf, $x, $y + 20, 'C', 'Times', '', 30, 'CERTIFICATE OF COMPLETION');
$pdf->SetTextColor(0, 0, 0);
certificate_print_text($pdf, $x, $y + 35, 'C', 'Times', '', 20,'This certificate is awarded to');
certificate_print_text($pdf, $x, $y + 51, 'C', 'Helvetica', '', 30, fullname($USER));
certificate_print_text($pdf, $x, $y + 70, 'C', 'Helvetica', '', 20, 'For participation in');
certificate_print_text($pdf, $x, $y + 87, 'C', 'Helvetica', '', 20, format_string($course->fullname));
certificate_print_text($pdf, $x, $y + 122, 'C', 'Times', '', 10, certificate_get_grade($certificate, $course));
certificate_print_text($pdf, $x, $y + 132, 'L', 'Times', '', 10, certificate_get_outcome($certificate, $course));
if ($certificate->printhours) {
    $pdf->SetTextColor(120, 0, 0);
    certificate_print_text($pdf, $x, $y + 102, 'C', 'Times', '', 20, 'CMRP IS AN ACCREDITED PROVIDER OF IACET® CEUs');
    certificate_print_text($pdf, $x, $y + 109, 'C', 'Times', '', 20, $certificate->printhours . ' CEUs AWARDED');
    $pdf->SetTextColor(0, 0, 0);
}
certificate_print_text($pdf, $x + 140, $y + 137, 'L', 'Helvetica', '', 11, certificate_get_date($certificate, $certrecord, $course));
certificate_print_text($pdf, $x + 15 , $y + 145, 'L', 'Helvetica', '', 11, 'Barbara van der Schalie, Clinical Training Manager');
certificate_print_text($pdf, $x, $codey, 'C', 'Times', '', 10, certificate_get_code($certificate, $certrecord));
$i = 0;
if ($certificate->printteacher) {
    $context = context_module::instance($cm->id);
    if ($teachers = get_users_by_capability($context, 'mod/certificate:printteacher', '', $sort = 'u.lastname ASC', '', '', '', '', false)) {
        foreach ($teachers as $teacher) {
            $i++;
            certificate_print_text($pdf, $sigx, $sigy + ($i * 4), 'L', 'Times', '', 12, fullname($teacher));
        }
    }
}

certificate_print_text($pdf, $x, 150, 'C', null, null, null, $certificate->customtext);


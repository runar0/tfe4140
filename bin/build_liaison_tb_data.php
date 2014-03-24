<?php

/**
 * Build all posible binary strings of a given length
 */
function buildString($length, $partial = "") {
    if (strlen($partial) == $length) {
        return [$partial];
    }
    return array_merge(
        buildString($length, $partial."0"),
        buildString($length, $partial."1")
    );
}

/**
 * Build all possible error combinations for a number of mcus, a given input length and a number of errors
 */
function buildErrorCombinations($mcus, $length, $errors, $curlength = 0, $failedmcus = []) {
    if($errors <= 0 || $errors > ($length - $curlength)) {
        return [];
    }
    $return = [];
    for($i = 0; $i < $mcus; $i++) {
        if(in_array($i, $failedmcus)) {
            continue;    
        }
        $newfailed = $failedmcus;
        $newfailed[] = $i;
        $nexterrors = buildErrorCombinations($mcus, $length, $errors-1, $curlength+1, $newfailed);
        foreach($nexterrors as $error) {
            $return[] = array_merge(
                [0 => ['mcu' => $i, 'bit' => $curlength]],
                $error
            ); 
        }
        $return[] = [0 => ['mcu' => $i, 'bit' => $curlength]];
    }    
    $return = array_merge($return, buildErrorCombinations($mcus, $length, $errors, $curlength+1, $failedmcus));
    
    if ($curlength == 0) {
        $return = array_filter($return, function ($element) use($errors) {
            return count($element) == $errors;
        });
    }
    
    return $return;
}


function generateOutput($inputs, $status) {        
    $word = strrev($inputs[0].$status);
    $d0 = (((int)$word{0}) + ((int)$word{1}) + ((int)$word{3}) + ((int)$word{4}) + ((int)$word{6}) + ((int)$word{8}) + ((int)$word{10})) % 2;
    $d1 = (((int)$word{0}) + ((int)$word{2}) + ((int)$word{3}) + ((int)$word{5}) + ((int)$word{6}) + ((int)$word{9}) + ((int)$word{10})) % 2;
    $d2 = (((int)$word{1}) + ((int)$word{2}) + ((int)$word{3}) + ((int)$word{7}) + ((int)$word{8}) + ((int)$word{9}) + ((int)$word{10})) % 2;
    $d3 = (((int)$word{4}) + ((int)$word{5}) + ((int)$word{6}) + ((int)$word{7}) + ((int)$word{8}) + ((int)$word{9}) + ((int)$word{10})) % 2;
    
    return strrev($word).$d3.$d2.$d1.$d0;
}

// Build all valid inputs
$validInputs = [];
foreach(buildString(8) as $input) {
    $validInputs[] = [$input, $input, $input, $input, "00000000"];
}

$oneErrorInputs = [];
// Generate all inputs with one error
foreach($validInputs as $input) {
    foreach(buildErrorCombinations(4, 8, 1) as $errorset) {
        foreach($errorset as $error) {
            $input[$error['mcu']]{$error['bit']} = (((int)$input[$error['mcu']]{$error['bit']}) + 1) % 2;
        }
        $oneErrorInputs[] = $input;
    }
}

$twoErrorInputs = [];
// Generate all inputs with two errors
foreach($validInputs as $input) {
    foreach(buildErrorCombinations(4, 8, 2) as $errorset) {
        foreach($errorset as $error) {
            $input[$error['mcu']]{$error['bit']} = (((int)$input[$error['mcu']]{$error['bit']}) + 1) % 2;
        }
        $twoErrorInputs[] = $input;
    }
}

$threeErrorInputs = [];
// Generate all inputs with three errors
foreach($validInputs as $input) {
    foreach(buildErrorCombinations(4, 8, 3) as $errorset) {
        foreach($errorset as $error) {
            $input[$error['mcu']]{$error['bit']} = (((int)$input[$error['mcu']]{$error['bit']}) + 1) % 2;
        }        
        $threeErrorInputs[] = $input;
    }
}

// Build final input array
$inputs = $validInputs;
$inputs[0][4] = "11111111";
foreach(array_merge($oneErrorInputs, $twoErrorInputs, $threeErrorInputs) as $input) {
    $input[4] = "11111111";
    $inputs[] = $input;
}

// Generate output table
$outputs = [];
foreach($validInputs as $input) {
    $outputs[] = generateOutput($input, "000");
}
foreach($oneErrorInputs as $input) {
    $outputs[] = generateOutput($input, "001");
}
foreach($twoErrorInputs as $input) {
    $outputs[] = generateOutput($input, "010");
}
foreach($threeErrorInputs as $input) {
    $outputs[] = generateOutput($input, "111");
}

// Create output
$template = file_get_contents(dirname(__DIR__).'/tests/liaison_tb_data.vhd.tpl');

$vhd_inputs = '';
$vhd_outputs = '';
foreach($inputs as $i => $input) {
    $output = $outputs[$i];
    
    $vhd_inputs .= sprintf(
        '            %d => (0 => "%s", 1 => "%s", 2 => "%s", 3 => "%s", 4 => "%s"),'."\n",
        $i, $input[0], $input[1], $input[2], $input[3], $input[4]
    );
    $vhd_outputs .= sprintf('            %d => "%s",'."\n", $i, $output);
}
$vhd_inputs = substr($vhd_inputs, 0, -2);
$vhd_outputs = substr($vhd_outputs, 0, -2);

$template = str_replace(array('{inputs}', '{outputs}', '{count}'), array($vhd_inputs, $vhd_outputs, count($outputs)), $template);
file_put_contents(dirname(__DIR__).'/tests/liaison_tb_data.vhd', $template);

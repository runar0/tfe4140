<?php

/**
 * Create an array of all possible binary strings of a given length
 */
function buildString($length, $length = "") {
    if (strlen($partial) == $length) {
        return [$partial];
    }
    return array_merge(
        buildString($partial."0", $length),
        buildString($partial."1", $length)
    );
}

/**
 * Build an array of all possible combinations of mcu number an bit number
 */
function buildAllMcuInputBitCombinations() {
    $output = [];
    for($mcu = 0; $mcu < 4; $mcu++) {
        for($bit = 0; $bit < 8; $bit++) {
            $output[] = ['mcu' => $mcu, 'bit' => $bit];
        }
    }
    return $output;
}

function buildPermuations($inputs, $maxerrors) {
    $return = [];
    $positions = buildAllMcuInputBitCombinations();
    
    foreach($inputs as $input) {
        $errors = [];
        for($i = 0; $i < count($positions); $i++) {
            $errors[] = $positions[$i];           
            // TODO if maxerrors > 1
            
            // Apply errors
            foreach($errors as $error) {            
                $modified = $input;
                $modified[$error['mcu']]{$error['bit']} = ($modified[$error['mcu']]{$error['bit']} + 1) % 2;
            }
            $return[] = $modified;
        }
    }
    return $return;
}

/**
 * Build all test input sets
 */
function buildInputAndOutputSets() {
    // Build all 256 combinations where all MCUs agree
    $goodinputs = [];
    foreach(buildString(8) as $input) {
        $goodinputs[] = [$input, $input, $input, $input];
    }
    
    // Create all one and two error combinations
    $oneerrinputs = buildPermuations($goodinputs, 1);
    //$twoerrinputs = buildPermuations($goodinputs, 2);
    
    $return = ['inputs' => [], 'outputs' => []];
    foreach($goodinputs as $input) {
        $input[4] = "00000000";
        $return['inputs'][] = $input;
        $return['outputs'][] = buildOutput($input, "000");
    }
    // Reset at first input
    $return['inputs'][0][4] = "11111111";
    
    foreach($onerrorinputs as $input) {
        $input[4] = "11111111";
        $return['inputs'][] = $input;
        $return['outputs'][] = buildOutput($input, "001");
    }
    
    return $return;
}

function buildOutput($inputs, $status) {
    $word = strrev($inputs[0].$status);
    $d0 = (((int)$word{0}) + ((int)$word{1}) + ((int)$word{3}) + ((int)$word{4}) + ((int)$word{6}) + ((int)$word{8}) + ((int)$word{10})) % 2;
    $d1 = (((int)$word{0}) + ((int)$word{2}) + ((int)$word{3}) + ((int)$word{5}) + ((int)$word{6}) + ((int)$word{9}) + ((int)$word{10})) % 2;
    $d2 = (((int)$word{1}) + ((int)$word{2}) + ((int)$word{3}) + ((int)$word{7}) + ((int)$word{8}) + ((int)$word{9}) + ((int)$word{10})) % 2;
    $d3 = (((int)$word{4}) + ((int)$word{5}) + ((int)$word{6}) + ((int)$word{7}) + ((int)$word{8}) + ((int)$word{9}) + ((int)$word{10})) % 2;
    
    return strrev($word).$d3.$d2.$d1.$d0;
}

$data = buildInputAndOutputSets();

// Create output
$template = file_get_contents(dirname(__DIR__).'/tests/liaison_tb_data.vhd.tpl');

$vhd_inputs = '';
$vhd_outputs = '';
foreach($data['inputs'] as $i => $input) {
    $output = $data['outputs'][$i];
    
    $vhd_inputs .= sprintf(
        '            %d => (0 => "%s", 1 => "%s", 2 => "%s", 3 => "%s", 4 => "%s"),'."\n",
        $i, $input[0], $input[1], $input[2], $input[3], $input[4]
    );
    $vhd_outputs .= sprintf('            %d => "%s",'."\n", $i, $output);
}
$vhd_inputs = substr($vhd_inputs, 0, -2);
$vhd_outputs = substr($vhd_outputs, 0, -2);

$template = str_replace(array('{inputs}', '{outputs}'), array($vhd_inputs, $vhd_outputs), $template);
file_put_contents(dirname(__DIR__).'/tests/liaison_tb_data.vhd', $template);

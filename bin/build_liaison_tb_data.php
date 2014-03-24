<?php

/**
 * Create an array of all possible binary strings of a given length
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
 * Build an array of all possible combinations of mcu number an bit number
 */
function buildAllMcuInputBitCombinations() {
    $output = [];
    //for($mcu = 0; $mcu < 4; $mcu++) {
    for($mcu = 0; $mcu < 1; $mcu++) {
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
        for($i = 0; $i < count($positions)-($maxerrors-1); $i++) {
            $e = [$positions[$i]];
            $errors = $maxerrors-1;
            while($errors > 0) {
                $err = $positions[$i+$maxerrors-$errors];
                $err['mcu'] += $maxerrors-$errors;
                $e[] = $err;
                $errors --;
            }
            
            // Apply errors         
            $modified = $input; 
            foreach($e as $error) {   
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
        
    $return = ['inputs' => [], 'outputs' => []];
    foreach($goodinputs as $input) {
        $input[4] = "00000000";
        $return['inputs'][] = $input;
        $return['outputs'][] = buildOutput($input, "000");
    }
    // Reset at first input
    $return['inputs'][0][4] = "11111111";
    
    foreach(buildPermuations($goodinputs, 1) as $input) {
        $input[4] = "11111111";
        $return['inputs'][] = $input;
        $return['outputs'][] = buildOutput($input, "001");
    }
    foreach(buildPermuations($goodinputs, 2) as $input) {
        $input[4] = "11111111";
        $return['inputs'][] = $input;
        $return['outputs'][] = buildOutput($input, "010");
    }
    /*foreach(buildPermuations($goodinputs, 3) as $input) {
        $input[4] = "11111111";
        $return['inputs'][] = $input;
        $return['outputs'][] = buildOutput($input, "111");
    } TODO  Third failure causes all voted data after that point to be 0, needs modified test */
    
    return $return;
}

function buildOutput($inputs, $status) {
    $word = strrev($inputs[3].$status);
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

$template = str_replace(array('{inputs}', '{outputs}', '{count}'), array($vhd_inputs, $vhd_outputs, count($data['inputs'])), $template);
file_put_contents(dirname(__DIR__).'/tests/liaison_tb_data.vhd', $template);

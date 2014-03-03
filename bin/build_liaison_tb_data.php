<?php


function buildString($partial, $length) {
    if (strlen($partial) == $length) {
        return [$partial];
    }
    return array_merge(
        buildString($partial."0", $length),
        buildString($partial."1", $length)
    );
}

function buildOutput($inputs) {
    static $status = "000"; // TODO Handle state changes
        
    $word = strrev($inputs[0].$status);
    $d0 = (((int)$word{0}) + ((int)$word{1}) + ((int)$word{3}) + ((int)$word{4}) + ((int)$word{6}) + ((int)$word{8}) + ((int)$word{10})) % 2;
    $d1 = (((int)$word{0}) + ((int)$word{2}) + ((int)$word{3}) + ((int)$word{5}) + ((int)$word{6}) + ((int)$word{9}) + ((int)$word{10})) % 2;
    $d2 = (((int)$word{1}) + ((int)$word{2}) + ((int)$word{3}) + ((int)$word{7}) + ((int)$word{8}) + ((int)$word{9}) + ((int)$word{10})) % 2;
    $d3 = (((int)$word{4}) + ((int)$word{5}) + ((int)$word{6}) + ((int)$word{7}) + ((int)$word{8}) + ((int)$word{9}) + ((int)$word{10})) % 2;
    
    return strrev($word).$d3.$d2.$d1.$d0;
}

$inputs = [];
foreach(buildString("", 8) as $input) {
    $inputs[] = [$input, $input, $input, $input, "00000000"];
}
$inputs[0][4] = "11111111";

$outputs = [];
foreach($inputs as $i =>  $input) {
    $outputs[] = buildOutput($input);
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

$template = str_replace(array('{inputs}', '{outputs}'), array($vhd_inputs, $vhd_outputs), $template);
file_put_contents(dirname(__DIR__).'/tests/liaison_tb_data.vhd', $template);

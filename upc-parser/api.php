<?php

function sanitize($str) {
	$str = stripcslashes($str);
    $str = htmlspecialchars($str, ENT_QUOTES, 'utf-8');
    return $str;
}

function file_get_contents_curl($url) {
    $ch = curl_init();

    curl_setopt($ch, CURLOPT_AUTOREFERER, TRUE);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, TRUE);       

    $data = curl_exec($ch);
    curl_close($ch);

    return $data;
}

function get_info($htmlcode) {
	$html = new DOMDocument();
	@$html->loadHTML($htmlcode);

	$infos = array();

	//Get all meta tags and loop through them.
	foreach($html->getElementsByTagName('meta') as $meta) {

		if($meta->getAttribute('property')) {
			$key = $meta->getAttribute('property');
		} else {
			$key = $meta->getAttribute('name');
		}

		$infos[$key] = $meta->getAttribute('content');
	}

	// get amount
	$xpath = new DOMXPath($html);
	$productInfoList = $xpath->query('//div[contains(attribute::class, "product-info-item-list")]')[0];
	foreach($productInfoList->childNodes as $child) {
		if($child->nodeName != 'div') continue;
		$productInfoDetail = $child->childNodes;
		if(trim($productInfoDetail[1]->textContent) != 'Menge / Grösse') continue;
		$infos['amount'] = trim($productInfoDetail[3]->textContent);
	}

	return $infos;
}

$q = sanitize($_GET['q']);
$data = file_get_contents_curl('http://www.codecheck.info/product.search?q='.$q);
$infos = get_info($data);

$result = array(
	'upc' => ($infos['og:title'] ? $q : null),
	'title' => $infos['og:title'],
	'image' => $infos['og:image'],
	'amount' => $infos['amount']
);

if(!$infos['og:title']) {
	header("HTTP/1.0 404 Not Found");
}

echo json_encode($result);
?>
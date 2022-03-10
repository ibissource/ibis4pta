<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:j="http://www.w3.org/2013/XSL/json">
	<xsl:output method="text" />

	<xsl:param name="filename">TestXSLTPipe_statistics_7.5-20191001.094540.json</xsl:param>
	<xsl:param name="fileTime">2019-12-07</xsl:param>
	<xsl:param name="filenamePartSeparator">_statistics_</xsl:param>
	<xsl:param name="sep">;</xsl:param>
	<xsl:param name="quot">"</xsl:param>

<xsl:template match="/">
	<xsl:variable name="array" select="fn:tokenize($filename,$filenamePartSeparator)" />
	<xsl:variable name="ibisVersion" select="substring($array[2],0,string-length($array[2])-4)" />
	<xsl:variable name="adapter" select="$array[1]" />
	<xsl:for-each select="j:map[j:string[@key='status']]">
		<xsl:value-of select="fn:concat(
$fileTime,$sep,
$quot,$ibisVersion,$quot,$sep,
$quot,$adapter,$quot,$sep,
$quot,j:string[@key='status'],$quot,$sep,
$quot,j:string[@key='error'],$quot)" />
		;
	</xsl:for-each>
	<xsl:for-each select="j:map/j:map[@key='totalMessageProccessingTime']">
		<xsl:call-template name="writeStatistics">
			<xsl:with-param name="ibisVersion" select="$ibisVersion" />
			<xsl:with-param name="adapter" select="$adapter" />
			<xsl:with-param name="object" select="'adapter'" />
		</xsl:call-template>
	</xsl:for-each>
	<xsl:for-each select="j:map/j:map[@key='durationPerPipe']/j:map">
		<xsl:call-template name="writeStatistics">
			<xsl:with-param name="ibisVersion" select="$ibisVersion" />
			<xsl:with-param name="adapter" select="$adapter" />
			<xsl:with-param name="object" select="'pipe'" />
		</xsl:call-template>
	</xsl:for-each>
</xsl:template>

<xsl:template name="writeStatistics">
	<xsl:param name="ibisVersion" />
	<xsl:param name="adapter" />
	<xsl:param name="object" />
	<xsl:variable name="name" select="concat(translate(substring(@key,1,1),'-=','__'),substring-before(concat(substring(@key,2),'$$'),'$$'))" />
	<xsl:value-of select="fn:concat(
$fileTime,$sep,
$quot,$ibisVersion,$quot,$sep,
$quot,$adapter,$quot,$sep,
$quot,$object,$quot,$sep,
$quot,$name,$quot,$sep,
j:*[@key='count'],$sep,
j:*[@key='min'],$sep,
j:*[@key='max'],$sep,
j:*[@key='avg'],$sep,
j:*[@key='stdDev'],$sep,
j:*[@key='sum'],$sep,
j:*[@key='first'],$sep,
j:*[@key='last'],$sep,
j:*[@key='p50'],$sep,
j:*[@key='p90'],$sep,
j:*[@key='p95'],$sep,
j:*[@key='p98'])" />
		;
</xsl:template>

</xsl:stylesheet>
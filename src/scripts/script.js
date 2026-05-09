const el = (id) => document.getElementById(id);
const serializer = new XMLSerializer();
const parser = new DOMParser();

function setStatus(msg, isError) {
  const s = el("status");
  s.textContent = msg;
  s.style.color = isError ? "crimson" : "#333";
}

const sampleXML = `<?xml version="1.0" encoding="utf-8"?>
<catalog>
<book id="bk101">
<author>Gambardella, Matthew</author>
<title>XML Developer's Guide</title>
<genre>Computer</genre>
<price>44.95</price>
<publish_date>2000-10-01</publish_date>
</book>
<book id="bk102">
<author>Ralls, Kim</author>
<title>Midnight Rain</title>
<genre>Fantasy</genre>
<price>5.95</price>
<publish_date>2000-12-16</publish_date>
</book>
</catalog>`;

const sampleXSLT = `<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" indent="yes" />
<xsl:template match="/">
<html>
<head><title>Book Catalog</title></head>
<body>
<h1>Book Catalog</h1>
<ul>
<xsl:for-each select="catalog/book">
<li>
  <strong><xsl:value-of select="title"/></strong>
  <em>by <xsl:value-of select="author"/></em>
  <span> — <xsl:value-of select="price"/></span>
</li>
</xsl:for-each>
</ul>
</body>
</html>
</xsl:template>
</xsl:stylesheet>`;

el("loadSample").addEventListener("click", () => {
  el("xmlInput").value = sampleXML;
  el("xsltInput").value = sampleXSLT;
  setStatus("Sample loaded");
});

el("showIframe").addEventListener("click", () => {
  el("iframeWrap").style.display = "block";
  el("rawOutput").style.display = "none";
  el("xmlOutput").style.display = "none";
});

el("showRaw").addEventListener("click", () => {
  el("iframeWrap").style.display = "none";
  el("rawOutput").style.display = "block";
  el("xmlOutput").style.display = "none";
});
el("showXmlTree").addEventListener("click", () => {
  el("iframeWrap").style.display = "none";
  el("rawOutput").style.display = "none";
  el("xmlOutput").style.display = "block";
});

function formatXml(xmlString) {
  try {
    const dom = parser.parseFromString(xmlString, "application/xml");
    if (dom.getElementsByTagName("parsererror").length) return xmlString;
    const xsltDoc = parser.parseFromString(
      [
        '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">',
        '<xsl:output method="xml" indent="yes"/>',
        '<xsl:template match="/"><xsl:copy-of select="."/></xsl:template>',
        "</xsl:stylesheet>",
      ].join(""),
      "application/xml",
    );
    const proc = new XSLTProcessor();
    proc.importStylesheet(xsltDoc);
    const out = proc.transformToDocument(dom);
    return serializer.serializeToString(out);
  } catch (e) {
    return xmlString;
  }
}

function transform() {
  setStatus("Transforming...");
  const xmlText = el("xmlInput").value;
  const xsltText = el("xsltInput").value;
  let xmlDoc, xsltDoc;
  try {
    xmlDoc = parser.parseFromString(xmlText, "application/xml");
    if (xmlDoc.getElementsByTagName("parsererror").length) {
      throw new Error("XML parse error");
    }
  } catch (err) {
    setStatus("XML parse error", true);
    return;
  }
  try {
    xsltDoc = parser.parseFromString(xsltText, "application/xml");
    if (xsltDoc.getElementsByTagName("parsererror").length) {
      throw new Error("XSLT parse error");
    }
  } catch (err) {
    setStatus("XSLT parse error", true);
    return;
  }

  try {
    const proc = new XSLTProcessor();
    proc.importStylesheet(xsltDoc);

    const outputMode = el("outputMode").value;
    const resultDoc = proc.transformToDocument
      ? proc.transformToDocument(xmlDoc)
      : proc.transformToFragment(xmlDoc, document);

    let outputStr;
    if (resultDoc instanceof Document) {
      outputStr = serializer.serializeToString(resultDoc);
    } else {
      const temp = document.implementation.createDocument("", "", null);
      temp.appendChild(resultDoc.cloneNode(true));
      outputStr = serializer.serializeToString(temp);
    }

    if (el("prettyXml").checked && el("outputMode").value === "xml") {
      outputStr = formatXml(outputStr);
    }

    el("rawOutput").textContent = outputStr;
    el("xmlOutput").textContent = outputStr.replace(/\r\n/g, "\n");

    const iframe = el("previewFrame");
    const blob = new Blob([outputStr], { type: "text/html" });
    const url = URL.createObjectURL(blob);

    iframe.src = url;
    iframe.onload = () => {
      URL.revokeObjectURL(url);
    };

    setStatus("Transform succeeded");
  } catch (err) {
    console.error(err);
    setStatus("Transformation error: " + (err.message || err), true);
  }
}

el("transformBtn").addEventListener("click", transform);
el("downloadResult").addEventListener("click", () => {
  const content = el("rawOutput").textContent || "";
  const blob = new Blob([content], { type: "application/xml" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = "result.xml";
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(a.href), 5000);
});

el("loadSample").click();
el("showIframe").click();

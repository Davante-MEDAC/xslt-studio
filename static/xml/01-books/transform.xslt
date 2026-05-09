<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" indent="yes"/>
  <xsl:template match="/">
    <html>
      <head>
        <title>Book Catalog</title>
        <style>
          body { font-family: Georgia, serif; max-width: 720px; margin: 40px auto; padding: 0 20px; color: #222; }
          h1 { font-size: 2rem; border-bottom: 2px solid #c00; padding-bottom: .4rem; }
          .book { margin: 1.5rem 0; padding: 1rem; border-left: 4px solid #c00; background: #fafafa; }
          .title { font-size: 1.2rem; font-weight: bold; }
          .author { color: #555; font-style: italic; }
          .meta { font-size: .85rem; color: #777; margin-top: .4rem; }
          .price { font-weight: bold; color: #c00; }
        </style>
      </head>
      <body>
        <h1>Book Catalog</h1>
        <xsl:for-each select="catalog/book">
          <div class="book">
            <div class="title"><xsl:value-of select="title"/></div>
            <div class="author">by <xsl:value-of select="author"/></div>
            <div class="meta">
              Genre: <xsl:value-of select="genre"/> &#160;|&#160;
              <span class="price">$<xsl:value-of select="price"/></span> &#160;|&#160;
              Published: <xsl:value-of select="publish_date"/>
            </div>
            <p><xsl:value-of select="description"/></p>
          </div>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

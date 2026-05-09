<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" indent="yes"/>
  <xsl:template match="/">
    <html>
      <head>
        <title>Product Inventory</title>
        <style>
          body { font-family: system-ui, sans-serif; margin: 30px; color: #1a1a2e; }
          h1 { color: #16213e; }
          table { border-collapse: collapse; width: 100%; box-shadow: 0 2px 8px rgba(0,0,0,.1); }
          thead { background: #16213e; color: #fff; }
          th, td { padding: 12px 16px; text-align: left; }
          tr:nth-child(even) { background: #f0f0f0; }
          tr:hover { background: #dde; }
          .badge { display:inline-block; padding:2px 8px; border-radius:12px; font-size:.8rem; }
          .electronics { background:#dbeafe; color:#1d4ed8; }
          .furniture { background:#dcfce7; color:#15803d; }
          .rating { color: #f59e0b; font-weight: bold; }
          .low-stock { color: #dc2626; font-weight: bold; }
        </style>
      </head>
      <body>
        <h1>Product Inventory</h1>
        <table>
          <thead>
            <tr>
              <th>SKU</th><th>Name</th><th>Category</th>
              <th>Price</th><th>Stock</th><th>Rating</th>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="products/product">
              <tr>
                <td><code><xsl:value-of select="@sku"/></code></td>
                <td><xsl:value-of select="name"/></td>
                <td>
                  <xsl:choose>
                    <xsl:when test="category='Electronics'">
                      <span class="badge electronics"><xsl:value-of select="category"/></span>
                    </xsl:when>
                    <xsl:otherwise>
                      <span class="badge furniture"><xsl:value-of select="category"/></span>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td>$<xsl:value-of select="price"/></td>
                <td>
                  <xsl:choose>
                    <xsl:when test="stock &lt; 20">
                      <span class="low-stock"><xsl:value-of select="stock"/> &#9888;</span>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="stock"/></xsl:otherwise>
                  </xsl:choose>
                </td>
                <td class="rating">&#9733; <xsl:value-of select="rating"/></td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

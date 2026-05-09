<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" indent="yes"/>
  <xsl:template match="/">
    <html>
      <head>
        <title>Company Directory</title>
        <style>
          body { font-family: system-ui, sans-serif; margin: 0; background: #f8fafc; color: #0f172a; }
          header { background: #0f172a; color: #fff; padding: 24px 32px; }
          header h1 { margin: 0; font-size: 1.6rem; }
          header p { margin: 4px 0 0; opacity: .6; font-size: .9rem; }
          main { padding: 24px 32px; }
          .dept { margin-bottom: 2rem; }
          .dept-title { font-size: 1rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: .08em; color: #64748b; margin-bottom: .75rem; }
          .cards { display: flex; gap: 1rem; flex-wrap: wrap; }
          .card { background: #fff; border-radius: 10px; padding: 16px 20px; min-width: 200px;
            box-shadow: 0 1px 4px rgba(0,0,0,.08); border-top: 3px solid #6366f1; }
          .card-name { font-weight: 700; font-size: 1rem; }
          .card-title { color: #6366f1; font-size: .85rem; margin: 2px 0 8px; }
          .card-meta { font-size: .8rem; color: #64748b; }
          .salary { font-weight: 600; color: #059669; }
        </style>
      </head>
      <body>
        <header>
          <h1><xsl:value-of select="company/@name"/></h1>
          <p>Employee Directory</p>
        </header>
        <main>
          <xsl:for-each select="company/department">
            <div class="dept">
              <div class="dept-title"><xsl:value-of select="@name"/></div>
              <div class="cards">
                <xsl:for-each select="employee">
                  <div class="card">
                    <div class="card-name"><xsl:value-of select="name"/></div>
                    <div class="card-title"><xsl:value-of select="title"/></div>
                    <div class="card-meta">
                      <span class="salary">$<xsl:value-of select="format-number(salary, '#,##0')"/></span>
                      &#160;&#183;&#160; Joined <xsl:value-of select="joined"/>
                    </div>
                  </div>
                </xsl:for-each>
              </div>
            </div>
          </xsl:for-each>
        </main>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

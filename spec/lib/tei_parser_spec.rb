require 'rails_helper'

RSpec.describe TeiParser do
  describe "The parse method" do
    let(:parse_result) do
      TeiParser.parse(result_tei)
    end

    let(:result_tei) do
      <<-xml
        <?xml version='1.0' encoding='utf-8'?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0" version="5.0">
          <teiHeader>
            <fileDesc>
              <titleStmt>
                <title>Testy document</title>
                <author>Testy author</author>
                <editor>Testy editor</editor>
                <respStmt xml:id="resp_1">
                  <resp>tesseract</resp>
                  <name>page segmentation</name>
                </respStmt>
                <respStmt xml:id="resp_2">
                  <resp>tesseract</resp>
                  <name>character recognition</name>
                </respStmt>
              </titleStmt>
              <publicationStmt>
                <publisher>Testy publisher</publisher>
                <authority>Testy authority</authority>
                <availability>
                  <licence>Available under CC Zero 1.0</licence>
                </availability>
              </publicationStmt>
            </fileDesc>
          </teiHeader>
          <sourceDoc>
            <surface lrx="1275" lry="1650" ulx="0" uly="0">
              <graphic url="test.corpusbuilder.com/testy_document.png"/>
              <zone>
                <line lrx="1050" lry="194" ulx="225" uly="186" xml:id="line_1" resp="#resp_1">
                  <zone lrx="1050" lry="194" type="segment" ulx="225" uly="186" xml:id="seg_1" resp="#resp_2">
                    <certainty degree="0.95" locus="value" target="#seg_1" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_1" ulx="225" uly="186" lrx="1050" lry="194" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="0.95" locus="value" target="#grapheme_1" resp="#resp_2"/>
                    </zone>
                  </zone>
                </line>
                <line lrx="924" lry="257" ulx="350" uly="232" xml:id="line_2" resp="#resp_1">
                  <zone lrx="924" lry="257" type="segment" ulx="779" uly="232" xml:id="seg_2" resp="#resp_2">
                    <certainty degree="0.15" locus="value" target="#seg_2" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_2" ulx="878" uly="232" lrx="924" lry="257" resp="#resp_2">
                      <seg>
                        <g>ا</g>
                      </seg>
                      <certainty degree="0.15" locus="value" target="#grapheme_2" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_3" ulx="866" uly="234" lrx="877" lry="257" resp="#resp_2">
                      <seg>
                        <g>ه</g>
                      </seg>
                      <certainty degree="0.15" locus="value" target="#grapheme_3" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_4" ulx="854" uly="240" lrx="864" lry="257" resp="#resp_2">
                      <seg>
                        <g>ق</g>
                      </seg>
                      <certainty degree="0.15" locus="value" target="#grapheme_4" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_5" ulx="845" uly="240" lrx="856" lry="257" resp="#resp_2">
                      <seg>
                        <g>ق</g>
                      </seg>
                      <certainty degree="0.15" locus="value" target="#grapheme_5" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_6" ulx="836" uly="240" lrx="844" lry="257" resp="#resp_2">
                      <seg>
                        <g>ي</g>
                      </seg>
                      <certainty degree="0.15" locus="value" target="#grapheme_6" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_7" ulx="830" uly="240" lrx="838" lry="257" resp="#resp_2">
                      <seg>
                        <g>ه</g>
                      </seg>
                      <certainty degree="0.15" locus="value" target="#grapheme_7" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_8" ulx="818" uly="234" lrx="829" lry="257" resp="#resp_2">
                      <seg>
                        <g>ه</g>
                      </seg>
                      <certainty degree="0.15" locus="value" target="#grapheme_8" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_9" ulx="806" uly="234" lrx="817" lry="257" resp="#resp_2">
                      <seg>
                        <g>ه</g>
                      </seg>
                      <certainty degree="0.15" locus="value" target="#grapheme_9" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_10" ulx="779" uly="232" lrx="804" lry="257" resp="#resp_2">
                      <seg>
                        <g>٨</g>
                      </seg>
                      <certainty degree="0.15" locus="value" target="#grapheme_10" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="770" lry="257" type="segment" ulx="665" uly="232" xml:id="seg_3" resp="#resp_2">
                    <certainty degree="1.00" locus="value" target="#seg_3" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_11" ulx="665" uly="232" lrx="675" lry="257" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="1.00" locus="value" target="#grapheme_11" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="770" lry="257" type="segment" ulx="675" uly="232" xml:id="seg_4" resp="#resp_2">
                    <certainty degree="0.16" locus="value" target="#seg_4" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_12" ulx="762" uly="232" lrx="770" lry="257" resp="#resp_2">
                      <seg>
                        <g>لم</g>
                      </seg>
                      <certainty degree="0.16" locus="value" target="#grapheme_12" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_13" ulx="744" uly="240" lrx="761" lry="257" resp="#resp_2">
                      <seg>
                        <g>ح</g>
                      </seg>
                      <certainty degree="0.16" locus="value" target="#grapheme_13" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_14" ulx="724" uly="240" lrx="743" lry="257" resp="#resp_2">
                      <seg>
                        <g>«</g>
                      </seg>
                      <certainty degree="0.16" locus="value" target="#grapheme_14" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_15" ulx="710" uly="240" lrx="722" lry="257" resp="#resp_2">
                      <seg>
                        <g>ع</g>
                      </seg>
                      <certainty degree="0.16" locus="value" target="#grapheme_15" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_16" ulx="700" uly="232" lrx="708" lry="257" resp="#resp_2">
                      <seg>
                        <g>أ</g>
                      </seg>
                      <certainty degree="0.16" locus="value" target="#grapheme_16" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_17" ulx="675" uly="232" lrx="699" lry="257" resp="#resp_2">
                      <seg>
                        <g>،</g>
                      </seg>
                      <certainty degree="0.16" locus="value" target="#grapheme_17" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="780" lry="257" type="segment" ulx="770" uly="232" xml:id="seg_5" resp="#resp_2">
                    <certainty degree="1.00" locus="value" target="#seg_5" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_18" ulx="770" uly="232" lrx="780" lry="257" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="1.00" locus="value" target="#grapheme_18" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="667" lry="257" type="segment" ulx="636" uly="232" xml:id="seg_6" resp="#resp_2">
                    <certainty degree="0.24" locus="value" target="#seg_6" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_19" ulx="661" uly="232" lrx="667" lry="257" resp="#resp_2">
                      <seg>
                        <g>ل</g>
                      </seg>
                      <certainty degree="0.24" locus="value" target="#grapheme_19" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_20" ulx="636" uly="232" lrx="663" lry="257" resp="#resp_2">
                      <seg>
                        <g>ك</g>
                      </seg>
                      <certainty degree="0.24" locus="value" target="#grapheme_20" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="700" lry="257" type="segment" ulx="667" uly="232" xml:id="seg_7" resp="#resp_2">
                    <certainty degree="1.00" locus="value" target="#seg_7" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_21" ulx="667" uly="232" lrx="700" lry="257" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="1.00" locus="value" target="#grapheme_21" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="625" lry="257" type="segment" ulx="515" uly="232" xml:id="seg_8" resp="#resp_2">
                    <certainty degree="0.10" locus="value" target="#seg_8" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_22" ulx="613" uly="240" lrx="625" lry="257" resp="#resp_2">
                      <seg>
                        <g>ح</g>
                      </seg>
                      <certainty degree="0.10" locus="value" target="#grapheme_22" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_23" ulx="603" uly="232" lrx="611" lry="257" resp="#resp_2">
                      <seg>
                        <g>لم</g>
                      </seg>
                      <certainty degree="0.10" locus="value" target="#grapheme_23" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_24" ulx="515" uly="232" lrx="602" lry="257" resp="#resp_2">
                      <seg>
                        <g>ي</g>
                      </seg>
                      <certainty degree="0.10" locus="value" target="#grapheme_24" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="700" lry="257" type="segment" ulx="625" uly="232" xml:id="seg_9" resp="#resp_2">
                    <certainty degree="1.00" locus="value" target="#seg_9" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_25" ulx="625" uly="232" lrx="700" lry="257" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="1.00" locus="value" target="#grapheme_25" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="506" lry="257" type="segment" ulx="350" uly="232" xml:id="seg_10" resp="#resp_2">
                    <certainty degree="0.11" locus="value" target="#seg_10" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_26" ulx="495" uly="234" lrx="506" lry="257" resp="#resp_2">
                      <seg>
                        <g>ه</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_26" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_27" ulx="483" uly="240" lrx="493" lry="257" resp="#resp_2">
                      <seg>
                        <g>ق</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_27" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_28" ulx="474" uly="240" lrx="485" lry="257" resp="#resp_2">
                      <seg>
                        <g>ق</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_28" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_29" ulx="465" uly="240" lrx="473" lry="257" resp="#resp_2">
                      <seg>
                        <g>ي</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_29" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_30" ulx="451" uly="240" lrx="467" lry="257" resp="#resp_2">
                      <seg>
                        <g>لا</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_30" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_31" ulx="382" uly="240" lrx="453" lry="257" resp="#resp_2">
                      <seg>
                        <g>ا</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_31" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_32" ulx="376" uly="240" lrx="384" lry="257" resp="#resp_2">
                      <seg>
                        <g>ه</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_32" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_33" ulx="350" uly="232" lrx="375" lry="257" resp="#resp_2">
                      <seg>
                        <g>»</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_33" resp="#resp_2"/>
                    </zone>
                  </zone>
                </line>
                <line lrx="1050" lry="290" ulx="225" uly="288" xml:id="line_3" resp="#resp_1">
                  <zone lrx="1050" lry="290" type="segment" ulx="225" uly="288" xml:id="seg_11" resp="#resp_2">
                    <certainty degree="0.95" locus="value" target="#seg_11" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_34" ulx="225" uly="288" lrx="1050" lry="290" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="0.95" locus="value" target="#grapheme_34" resp="#resp_2"/>
                    </zone>
                  </zone>
                </line>
                <line lrx="950" lry="370" ulx="307" uly="351" xml:id="line_4" resp="#resp_1">
                  <zone lrx="950" lry="370" type="segment" ulx="833" uly="352" xml:id="seg_12" resp="#resp_2">
                    <certainty degree="0.07" locus="value" target="#seg_12" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_35" ulx="943" uly="356" lrx="950" lry="366" resp="#resp_2">
                      <seg>
                        <g>ل</g>
                      </seg>
                      <certainty degree="0.07" locus="value" target="#grapheme_35" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_36" ulx="939" uly="356" lrx="945" lry="366" resp="#resp_2">
                      <seg>
                        <g>ا</g>
                      </seg>
                      <certainty degree="0.07" locus="value" target="#grapheme_36" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_37" ulx="932" uly="352" lrx="938" lry="367" resp="#resp_2">
                      <seg>
                        <g>لم</g>
                      </seg>
                      <certainty degree="0.07" locus="value" target="#grapheme_37" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_38" ulx="892" uly="355" lrx="934" lry="370" resp="#resp_2">
                      <seg>
                        <g>-</g>
                      </seg>
                      <certainty degree="0.07" locus="value" target="#grapheme_38" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_39" ulx="880" uly="352" lrx="891" lry="366" resp="#resp_2">
                      <seg>
                        <g>ظ</g>
                      </seg>
                      <certainty degree="0.07" locus="value" target="#grapheme_39" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_40" ulx="872" uly="356" lrx="879" lry="366" resp="#resp_2">
                      <seg>
                        <g>ل</g>
                      </seg>
                      <certainty degree="0.07" locus="value" target="#grapheme_40" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_41" ulx="838" uly="352" lrx="874" lry="366" resp="#resp_2">
                      <seg>
                        <g>ا</g>
                      </seg>
                      <certainty degree="0.07" locus="value" target="#grapheme_41" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_42" ulx="833" uly="352" lrx="840" lry="366" resp="#resp_2">
                      <seg>
                        <g>ل</g>
                      </seg>
                      <certainty degree="0.07" locus="value" target="#grapheme_42" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="960" lry="370" type="segment" ulx="950" uly="352" xml:id="seg_13" resp="#resp_2">
                    <certainty degree="1.00" locus="value" target="#seg_13" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_43" ulx="950" uly="352" lrx="960" lry="370" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="1.00" locus="value" target="#grapheme_43" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="826" lry="370" type="segment" ulx="772" uly="352" xml:id="seg_14" resp="#resp_2">
                    <certainty degree="0.11" locus="value" target="#seg_14" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_44" ulx="817" uly="356" lrx="826" lry="370" resp="#resp_2">
                      <seg>
                        <g>٢</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_44" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_45" ulx="810" uly="356" lrx="817" lry="366" resp="#resp_2">
                      <seg>
                        <g>لم</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_45" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_46" ulx="787" uly="356" lrx="812" lry="366" resp="#resp_2">
                      <seg>
                        <g>س</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_46" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_47" ulx="776" uly="352" lrx="787" lry="366" resp="#resp_2">
                      <seg>
                        <g>ك</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_47" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_48" ulx="772" uly="352" lrx="778" lry="366" resp="#resp_2">
                      <seg>
                        <g>ا</g>
                      </seg>
                      <certainty degree="0.11" locus="value" target="#grapheme_48" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="900" lry="366" type="segment" ulx="826" uly="351" xml:id="seg_15" resp="#resp_2">
                    <certainty degree="1.00" locus="value" target="#seg_15" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_49" ulx="826" uly="351" lrx="900" lry="366" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="1.00" locus="value" target="#grapheme_49" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="742" lry="366" type="segment" ulx="681" uly="351" xml:id="seg_16" resp="#resp_2">
                    <certainty degree="0.05" locus="value" target="#seg_16" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_50" ulx="736" uly="356" lrx="742" lry="366" resp="#resp_2">
                      <seg>
                        <g>ب</g>
                      </seg>
                      <certainty degree="0.05" locus="value" target="#grapheme_50" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_51" ulx="729" uly="356" lrx="734" lry="366" resp="#resp_2">
                      <seg>
                        <g>ي</g>
                      </seg>
                      <certainty degree="0.05" locus="value" target="#grapheme_51" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_52" ulx="726" uly="356" lrx="731" lry="366" resp="#resp_2">
                      <seg>
                        <g>ه</g>
                      </seg>
                      <certainty degree="0.05" locus="value" target="#grapheme_52" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_53" ulx="681" uly="351" lrx="726" lry="366" resp="#resp_2">
                      <seg>
                        <g>ا</g>
                      </seg>
                      <certainty degree="0.05" locus="value" target="#grapheme_53" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="800" lry="366" type="segment" ulx="742" uly="351" xml:id="seg_17" resp="#resp_2">
                    <certainty degree="1.00" locus="value" target="#seg_17" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_54" ulx="742" uly="351" lrx="800" lry="366" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="1.00" locus="value" target="#grapheme_54" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="675" lry="366" type="segment" ulx="635" uly="351" xml:id="seg_18" resp="#resp_2">
                    <certainty degree="0.22" locus="value" target="#seg_18" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_55" ulx="656" uly="356" lrx="675" lry="366" resp="#resp_2">
                      <seg>
                        <g>م</g>
                      </seg>
                      <certainty degree="0.22" locus="value" target="#grapheme_55" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_56" ulx="650" uly="352" lrx="655" lry="366" resp="#resp_2">
                      <seg>
                        <g>لم</g>
                      </seg>
                      <certainty degree="0.22" locus="value" target="#grapheme_56" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_57" ulx="635" uly="351" lrx="649" lry="366" resp="#resp_2">
                      <seg>
                        <g>٨</g>
                      </seg>
                      <certainty degree="0.22" locus="value" target="#grapheme_57" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="700" lry="366" type="segment" ulx="675" uly="352" xml:id="seg_19" resp="#resp_2">
                    <certainty degree="1.00" locus="value" target="#seg_19" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_58" ulx="675" uly="352" lrx="700" lry="366" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="1.00" locus="value" target="#grapheme_58" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="606" lry="366" type="segment" ulx="556" uly="352" xml:id="seg_20" resp="#resp_2">
                    <certainty degree="0.08" locus="value" target="#seg_20" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_59" ulx="599" uly="356" lrx="606" lry="366" resp="#resp_2">
                      <seg>
                        <g>ع</g>
                      </seg>
                      <certainty degree="0.08" locus="value" target="#grapheme_59" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_60" ulx="573" uly="356" lrx="598" lry="366" resp="#resp_2">
                      <seg>
                        <g>س</g>
                      </seg>
                      <certainty degree="0.08" locus="value" target="#grapheme_60" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_61" ulx="562" uly="352" lrx="572" lry="366" resp="#resp_2">
                      <seg>
                        <g>ل</g>
                      </seg>
                      <certainty degree="0.08" locus="value" target="#grapheme_61" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_62" ulx="556" uly="352" lrx="564" lry="366" resp="#resp_2">
                      <seg>
                        <g>ا</g>
                      </seg>
                      <certainty degree="0.08" locus="value" target="#grapheme_62" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="700" lry="366" type="segment" ulx="606" uly="351" xml:id="seg_21" resp="#resp_2">
                    <certainty degree="1.00" locus="value" target="#seg_21" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_63" ulx="606" uly="351" lrx="700" lry="366" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="1.00" locus="value" target="#grapheme_63" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="550" lry="366" type="segment" ulx="486" uly="351" xml:id="seg_22" resp="#resp_2">
                    <certainty degree="0.14" locus="value" target="#seg_22" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_64" ulx="533" uly="356" lrx="550" lry="366" resp="#resp_2">
                      <seg>
                        <g>ى</g>
                      </seg>
                      <certainty degree="0.14" locus="value" target="#grapheme_64" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_65" ulx="527" uly="352" lrx="532" lry="366" resp="#resp_2">
                      <seg>
                        <g>لم</g>
                      </seg>
                      <certainty degree="0.14" locus="value" target="#grapheme_65" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_66" ulx="508" uly="356" lrx="526" lry="366" resp="#resp_2">
                      <seg>
                        <g>م</g>
                      </seg>
                      <certainty degree="0.14" locus="value" target="#grapheme_66" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_67" ulx="501" uly="351" lrx="506" lry="366" resp="#resp_2">
                      <seg>
                        <g>ل</g>
                      </seg>
                      <certainty degree="0.14" locus="value" target="#grapheme_67" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_68" ulx="489" uly="352" lrx="500" lry="366" resp="#resp_2">
                      <seg>
                        <g>لا</g>
                      </seg>
                      <certainty degree="0.14" locus="value" target="#grapheme_68" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_69" ulx="486" uly="352" lrx="491" lry="366" resp="#resp_2">
                      <seg>
                        <g>ل</g>
                      </seg>
                      <certainty degree="0.14" locus="value" target="#grapheme_69" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="600" lry="366" type="segment" ulx="550" uly="351" xml:id="seg_23" resp="#resp_2">
                    <certainty degree="1.00" locus="value" target="#seg_23" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_70" ulx="550" uly="351" lrx="600" lry="366" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="1.00" locus="value" target="#grapheme_70" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="458" lry="366" type="segment" ulx="410" uly="351" xml:id="seg_24" resp="#resp_2">
                    <certainty degree="0.06" locus="value" target="#seg_24" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_71" ulx="430" uly="351" lrx="458" lry="366" resp="#resp_2">
                      <seg>
                        <g>ا</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_71" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_72" ulx="420" uly="352" lrx="429" lry="366" resp="#resp_2">
                      <seg>
                        <g>لم</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_72" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_73" ulx="410" uly="352" lrx="422" lry="366" resp="#resp_2">
                      <seg>
                        <g>ط</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_73" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="500" lry="370" type="segment" ulx="458" uly="352" xml:id="seg_25" resp="#resp_2">
                    <certainty degree="1.00" locus="value" target="#seg_25" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_74" ulx="458" uly="352" lrx="500" lry="370" resp="#resp_2">
                      <seg>
                        <g> </g>
                      </seg>
                      <certainty degree="1.00" locus="value" target="#grapheme_74" resp="#resp_2"/>
                    </zone>
                  </zone>
                  <zone lrx="405" lry="370" type="segment" ulx="307" uly="352" xml:id="seg_26" resp="#resp_2">
                    <certainty degree="0.06" locus="value" target="#seg_26" resp="#resp_2"/>
                    <zone type="grapheme" xml:id="grapheme_75" ulx="396" uly="356" lrx="405" lry="366" resp="#resp_2">
                      <seg>
                        <g>ع</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_75" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_76" ulx="385" uly="356" lrx="395" lry="370" resp="#resp_2">
                      <seg>
                        <g>و</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_76" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_77" ulx="377" uly="356" lrx="384" lry="366" resp="#resp_2">
                      <seg>
                        <g>ق</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_77" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_78" ulx="357" uly="356" lrx="379" lry="370" resp="#resp_2">
                      <seg>
                        <g>هم</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_78" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_79" ulx="349" uly="352" lrx="356" lry="366" resp="#resp_2">
                      <seg>
                        <g>ل</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_79" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_80" ulx="339" uly="355" lrx="351" lry="366" resp="#resp_2">
                      <seg>
                        <g>ع</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_80" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_81" ulx="336" uly="355" lrx="341" lry="366" resp="#resp_2">
                      <seg>
                        <g>ه</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_81" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_82" ulx="330" uly="352" lrx="335" lry="366" resp="#resp_2">
                      <seg>
                        <g>ا</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_82" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_83" ulx="320" uly="356" lrx="329" lry="366" resp="#resp_2">
                      <seg>
                        <g>و</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_83" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_84" ulx="320" uly="356" lrx="324" lry="366" resp="#resp_2">
                      <seg>
                        <g>ه</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_84" resp="#resp_2"/>
                    </zone>
                    <zone type="grapheme" xml:id="grapheme_85" ulx="307" uly="352" lrx="320" lry="366" resp="#resp_2">
                      <seg>
                        <g>٧</g>
                      </seg>
                      <certainty degree="0.06" locus="value" target="#grapheme_85" resp="#resp_2"/>
                    </zone>
                  </zone>
                </line>
              </zone>
            </surface>
          </surfaceDoc>
        </TEI>
      xml
    end

    it "returns the Parser::Result when fed with proper data" do
      expect(parse_result).to be_an_instance_of(TeiParser)
    end

    context "result" do
      let(:surfaces) do
          parse_result.elements.select { |el| el.name == "surface" }
      end

      let(:zones) do
          parse_result.elements.select { |el| el.name == "zone" }
      end

      let(:graphemes) do
          parse_result.elements.select { |el| el.name == "grapheme" }
      end

      it "contains the elements enumerator" do
        expect(parse_result.elements).to be_an_instance_of(Enumerator::Lazy)
      end

      it "contains a proper number of surface elements" do
        expect(surfaces.count).to eq(1)
      end

      it "contains a proper number of zone elements" do
        expect(zones.count).to eq(26)
      end

      it "contains a proper number of grapheme elements" do
        expect(graphemes.count).to eq(85)
      end

      it "gathers proper grapheme values" do
        expect(graphemes.take(5).map(&:value).to_a.join).to eq(" اهقق")
      end

      it "gathers proper grapheme certainty values" do
        expect(graphemes.take(5).map(&:certainty).to_a).to eq([0.95, 0.15, 0.15, 0.15, 0.15])
      end

      context "items being a surface" do
        let(:surface) do
          surfaces.first
        end

        it "contains the area attribute" do
          expect(surface).to respond_to(:area)
        end

        it "contains proper values for the area attribute" do
          expect(surface.area.lrx).to eq(1275)
          expect(surface.area.lry).to eq(1650)
          expect(surface.area.ulx).to eq(0)
          expect(surface.area.uly).to eq(0)
        end
      end

      context "items being a zone" do
        let(:zone) do
          zones.first
        end

        it "contains the area attribute" do
          expect(zone).to respond_to(:area)
        end

        it "contains proper values for the area attribute" do
          expect(zone.area.lrx).to eq(1050)
          expect(zone.area.lry).to eq(194)
          expect(zone.area.ulx).to eq(225)
          expect(zone.area.uly).to eq(186)
        end
      end

      context "items being a grapheme" do
        let(:grapheme) do
          graphemes.first
        end

        it "contains the area attribute" do
          expect(grapheme).to respond_to(:area)
        end

        it "contains the certainty attribute" do
          expect(grapheme).to respond_to(:certainty)
        end

        it "contains proper values for the area attribute" do
          expect(grapheme.area.lrx).to eq(1050)
          expect(grapheme.area.lry).to eq(194)
          expect(grapheme.area.ulx).to eq(225)
          expect(grapheme.area.uly).to eq(186)
        end
      end
    end
  end
end

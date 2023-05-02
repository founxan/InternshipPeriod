report 50113 PurchaseOrderreport
{
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = Normal;
    CaptionML = ENU = 'MyPurchaseOrder';
    RDLCLayout = 'RDLPurchaseOrderreport.rdl';


    dataset
    {
        dataitem(Vendor; Vendor)
        {
            RequestFilterFields = "No.";
            column(vendorNo; vendorNo) { }
            column(vendorName; Name) { }

            dataitem(POQTT; POQueryTempTable)
            {
                RequestFilterFields = ReceiptNo;
                column(DirectUnitCost_POQTT; DirectUnitCost) { }
                column(No_POQTT; No) { }
                column(Description_POQTT; Description) { }
                column(CurrencyCode_POQTT; CurrencyCode) { }
                column(LineAmount_POQTT; Line_Amount) { }
                column(VAT_POQTT; VATProdPostingGroup) { }
                column(RowNo_POQTT; RowNo) { }
                column(BuyFromVendorNo_POQTT; BuyFromVendorNo_PL) { }
                column(PONo_POQTT; PurchaseOrderNo) { }
                column(SourceNo_POQTT; SourceNo_PostedWhseReceiptLine) { }//PostedWhseReceiptLine
                column(QtyRcdNotInvoiced_POQTT; QtyRcdNotInvoiced_PL) { }
                column(startdate; startdateReq) { }
                column(enddate; enddateReq) { }
                column(itemNo; itemNo) { }

                column(ReceiptNo; ReceiptNo) { }
                column(OrderNo; OrderNo) { }
            }

            trigger OnAfterGetRecord()
            var
                POQ: Query VendorFilterQuery;

            begin
                // vendorNo := Vendor.GetFilter("No.");//retrieve request page filter
                vendorNo := "No.";
                receiptNo := ReceiptNo;
                POQTT.Reset();
                POQTT.DeleteAll();
                POQ.SetRange(BuyfromVendorNo_PL, vendorNo);
                POQ.SetRange(OrderNo_PurchRcptLine, receiptNo);
                POQ.SetFilter(QtyRcdNotInvoiced_PL, '>0');//QtyRcdNotInvoiced filter
                if POQ.Open() then begin
                    while POQ.Read() do begin
                        //add query to temp record study: https://yzhums.com/4869/ https://yzhums.com/34290/
                        POQTT.Init();
                        POQTT.RowNo := POQTT.RowNo + 1;
                        POQTT.PurchaseOrderNo := POQ.SourceNo_PostedWhseReceiptLine;
                        POQTT.BuyFromVendorNo_PL := POQ.BuyfromVendorNo_PL;
                        POQTT.SourceNo_PostedWhseReceiptLine := POQ.No_PostedWhseReceiptLine;
                        POQTT.QtyRcdNotInvoiced_PL := POQ.QtyRcdNotInvoiced_PL;
                        POQTT.VATProdPostingGroup := POQ.VATProdPostingGroup_PurchaseLine;
                        POQTT.Line_Amount := POQ.Line_Amount;
                        POQTT.CurrencyCode := POQ.CurrencyCode;
                        POQTT.No := POQ.itemNo;
                        POQTT.Description := POQ.Description;
                        POQTT.DirectUnitCost := POQ.DirectUnitCost_PurchaseLine;
                        POQTT.itemNo := POQ.itemNo;

                        POQTT.ReceiptNo := POQ.ReceiptNo;
                        POQTT.OrderNo := POQ.OrderNo_PurchRcptLine;
                        POQTT.Insert();
                    end;
                    POQ.Close();
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                field(enddate; enddateReq)
                {
                    Caption = 'end date';
                    ApplicationArea = all;
                    trigger OnValidate()
                    begin
                        if enddateReq - startdateReq <= 0 then begin
                            Message('結束日期早於起始日期');
                            enddateReq := WorkDate;
                        end;
                    end;
                }
            }
        }

        trigger OnOpenPage()
        var
            Question: Text;
            Answer: Boolean;
            VendorNo: Integer;
            Text000: Label 'Exit without saving changes to vendor %1?';
        //Text001: Label 'You selected %1.';
        begin
            VendorNo := 10000;
            Question := Text000;
            Answer := Dialog.Confirm(Question, true, VendorNo);
            //Message(Text001, Answer);

            startdateReq := WorkDate;
            if (enddateReq = 0D) then begin
                enddateReq := WorkDate;
            end
            // Vendor.SetFilter("No.", '=%1', vendorNo);
        end;
    }

    // trigger OnPreReport()

    // procedure "setMyNo."(var "no.": Code[100])
    // begin
    //     no := "no.";
    // end;

    #region
    // procedure PurchaseLineTempRecordGroupMethod()
    // var
    //     PurchaseLine: Record "Purchase Line";
    //     TempPurchaseLineResult: Record "Purchase Line" temporary;
    //     GroupNo: Integer;
    // begin
    //     PurchaseLine.SetCurrentKey("Currency Code", "VAT Prod. Posting Group");
    //     if PurchaseLine.FindSet() then
    //         repeat
    //             //Check if group is exist
    //             TempPurchaseLineResult.SetRange("Currency Code", PurchaseLine."Currency Code");
    //             TempPurchaseLineResult.SetRange("VAT Prod. Posting Group", PurchaseLine."VAT Prod. Posting Group");
    //             if not TempPurchaseLineResult.FindFirst() then begin
    //                 //New group record initialization
    //                 GroupNo += 1;
    //                 TempPurchaseLineResult := PurchaseLine;
    //                 TempPurchaseLineResult.Insert();
    //             end else begin
    //                 //Continuation of the group
    //                 //here you can update values for group, maybe sum some amounts, etc.
    //                 TempPurchaseLineResult.Modify();
    //             end;
    //         until PurchaseLine.Next() = 0;
    // end;
    #endregion

    var
        //no: code[100];
        startdateReq: Date;
        enddateReq: Date;
        vendorNo: Code[90];
        receiptNo: Code[90];
}

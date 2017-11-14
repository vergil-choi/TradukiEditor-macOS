//
//  Parser.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/9/26.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//


// TODO: Maybe need ParserGate, WriterGate and ReaderGate to hide the detail from high level call


protocol Parser {
    func parseFile(_ file: String) -> SyntaxContext
    
}

protocol FileWriter {
    
}

protocol FileReader {
    
}


protocol SQLWriter {
    
}

protocol SQLReader {
    
}

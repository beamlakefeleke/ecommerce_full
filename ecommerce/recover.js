const fs = require('fs');
const p = 'C:/Users/bamlake.feleke/.gemini/antigravity-ide/brain/2fb3a570-2ac4-4aef-968d-1314ba7b5903/.system_generated/logs/transcript_full.jsonl';
const lines = fs.readFileSync(p, 'utf8').split('\n');
for(let i=0; i<lines.length; i++) {
  if (lines[i]) {
    try {
      const obj = JSON.parse(lines[i]);
      if (obj.tool_responses) {
        for(let tr of obj.tool_responses) {
          if (tr.output && tr.output.includes("import 'package:flutter/cupertino.dart';") && tr.output.includes("class CheckoutButton extends StatelessWidget")) {
             console.log('Found full output!');
             fs.writeFileSync('restored_cart_screen.dart', tr.output);
             process.exit(0);
          }
        }
      }
    } catch(e) {}
  }
}
console.log('Not found');

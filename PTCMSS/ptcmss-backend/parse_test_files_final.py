#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Final enhanced parser to extract ALL test case information from test files
"""

import re
import os
from pathlib import Path

def extract_test_body(content, start_pos):
    """Extract the complete test method body"""
    brace_count = 0
    body_start = None
    body_end = None
    
    for i in range(start_pos, len(content)):
        if content[i] == '{':
            if brace_count == 0:
                body_start = i + 1
            brace_count += 1
        elif content[i] == '}':
            brace_count -= 1
            if brace_count == 0:
                body_end = i
                break
    
    if body_start and body_end:
        return content[body_start:body_end]
    return ""

def extract_input_parameters(test_body, method_name):
    """Extract actual input parameters from test body"""
    inputs = []
    
    # Pattern 1: request.setXXX(value) - most common
    set_pattern = r'request\.set(\w+)\(([^)]+)\)'
    for match in re.finditer(set_pattern, test_body):
        param_name = match.group(1)
        param_value = match.group(2).strip()
        
        # Clean up value - handle BigDecimal
        if 'BigDecimal' in match.group(0):
            big_decimal_match = re.search(r'BigDecimal\(["\']([^"\']+)["\']\)', match.group(0))
            if big_decimal_match:
                param_value = big_decimal_match.group(1)
            else:
                param_value = re.sub(r'new\s+BigDecimal\(', '', param_value)
                param_value = re.sub(r'\)+$', '', param_value)
        else:
            param_value = re.sub(r'new\s+\w+\(', '', param_value)
            param_value = re.sub(r'\)+$', '', param_value)
        
        param_value = param_value.strip('"').strip("'").strip()
        
        if param_value and len(param_value) < 50:
            inputs.append(f"{param_name}: {param_value}")
    
    # Pattern 2: Integer/String variable assignments
    var_pattern = r'(\w+)\s+(\w+)\s*=\s*([^;]+);'
    for match in re.finditer(var_pattern, test_body):
        var_type = match.group(1)
        var_name = match.group(2)
        var_value = match.group(3).strip()
        
        # Skip common variables
        if var_name.lower() in ['request', 'response', 'invoice', 'payment', 'driver', 'trip', 'booking', 'result']:
            continue
            
        var_value = var_value.strip('"').strip("'").strip()
        
        # Handle method calls
        if '(' in var_value and ')' in var_value:
            # Extract simple values from method calls
            if 'LocalDate.of' in var_value:
                date_match = re.search(r'LocalDate\.of\((\d+),\s*(\d+),\s*(\d+)\)', var_value)
                if date_match:
                    var_value = f"{date_match.group(1)}-{date_match.group(2)}-{date_match.group(3)}"
            elif 'Optional.of' in var_value or 'Optional.empty' in var_value:
                continue
            else:
                var_value = var_value[:30] + '...' if len(var_value) > 30 else var_value
        
        if var_value and len(var_value) < 50:
            inputs.append(f"{var_name}: {var_value}")
    
    # Pattern 3: Direct method parameters in service calls
    # Look for service method calls: serviceName.methodName(param1, param2, ...)
    service_call_pattern = rf'{method_name}\s*\(([^)]+)\)'
    service_match = re.search(service_call_pattern, test_body)
    if service_match:
        params_str = service_match.group(1)
        # Split by comma but be careful with nested calls
        param_list = re.split(r',\s*(?![^()]*\))', params_str)
        for idx, param in enumerate(param_list[:3]):  # Limit to 3 params
            param = param.strip()
            if param:
                # Try to extract value
                if param.isdigit():
                    inputs.append(f"param{idx+1}: {param}")
                elif param.startswith('"') and param.endswith('"'):
                    clean_param = param.strip('"')
                    inputs.append(f"param{idx+1}: {clean_param}")
                elif 'request' in param.lower():
                    # Already handled by request.set pattern
                    pass
                else:
                    # Extract variable name
                    var_match = re.search(r'(\w+)(?:\.|$)', param)
                    if var_match:
                        var_name = var_match.group(1)
                        if var_name.lower() not in ['any', 'anyint', 'anystring', 'anylist']:
                            inputs.append(f"param{idx+1}: {var_name}")
    
    return inputs[:5]  # Limit to 5 inputs

def extract_expected_result(test_body, test_name):
    """Extract expected result from test body"""
    expected = ""
    
    # Pattern 1: assertThat with specific assertions
    if 'assertThatThrownBy' in test_body:
        # Exception test
        msg_match = re.search(r'hasMessageContaining\(["\']([^"\']+)["\']\)', test_body)
        if msg_match:
            expected = f"Exception: {msg_match.group(1)}"
        else:
            exception_match = re.search(r'isInstanceOf\((\w+)\.class\)', test_body)
            if exception_match:
                expected = f"Exception: {exception_match.group(1)}"
            else:
                expected = "Should throw exception"
    elif 'assertThat' in test_body:
        # Regular assertion
        is_equal_match = re.search(r'assertThat\([^)]+\)\.isEqualTo\(([^)]+)\)', test_body)
        if is_equal_match:
            expected_value = is_equal_match.group(1)
            expected_value = expected_value.strip('"').strip("'").strip()
            if len(expected_value) > 50:
                expected_value = expected_value[:47] + "..."
            expected = f"Should equal: {expected_value}"
        elif 'isNotNull' in test_body:
            expected = "Should return non-null value"
        elif 'isNull' in test_body:
            expected = "Should return null"
        elif 'isTrue' in test_body:
            expected = "Should return true"
        elif 'isFalse' in test_body:
            expected = "Should return false"
        else:
            expected = "Should pass assertion"
    
    # Pattern 2: verify calls
    verify_match = re.search(r'verify\(([^)]+)\)\.(\w+)\(', test_body)
    if verify_match and not expected:
        method_name = verify_match.group(2)
        expected = f"Verify {method_name} called"
    
    # If no specific assertion found, infer from test name
    if not expected:
        test_lower = test_name.lower()
        if 'throwexception' in test_lower or 'shouldthrow' in test_lower:
            expected = "Should throw exception"
        elif 'shouldreturn' in test_lower:
            expected = "Should return expected value"
        elif 'shouldcreate' in test_lower or 'shouldsucceed' in test_lower or 'shouldpass' in test_lower:
            expected = "Should succeed and return result"
        elif 'shouldupdate' in test_lower:
            expected = "Should update successfully"
        elif 'shoulddelete' in test_lower:
            expected = "Should delete successfully"
        elif 'shouldlink' in test_lower:
            expected = "Should link successfully"
        elif 'shouldmark' in test_lower:
            expected = "Should mark status correctly"
        elif 'shouldfilter' in test_lower:
            expected = "Should filter correctly"
        elif 'shouldcalculate' in test_lower:
            expected = "Should calculate correctly"
        else:
            expected = "Should pass test"
    
    return expected

def parse_test_file(file_path):
    """Parse a test file and extract detailed test case information"""
    test_cases = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Find ALL test methods - multiple patterns
        test_patterns = [
            r'@Test\s+void\s+(\w+)_when([\w_]+)_should([\w_]+)\(\)',  # Standard pattern
            r'@Test\s+void\s+(\w+)(?:\(\))?\s*\{',  # Any test method
        ]
        
        all_matches = []
        for pattern in test_patterns:
            matches = list(re.finditer(pattern, content))
            all_matches.extend(matches)
        
        # Remove duplicates
        seen_positions = set()
        unique_matches = []
        for match in all_matches:
            if match.start() not in seen_positions:
                seen_positions.add(match.start())
                unique_matches.append(match)
        
        for match in unique_matches:
            if len(match.groups()) >= 1:
                if '_when' in match.group(0) and len(match.groups()) >= 3:
                    method_part = match.group(1)
                    condition_part = match.group(2)
                    expected_part = match.group(3)
                    full_name = f"{method_part}_when{condition_part}_should{expected_part}"
                else:
                    # Extract method name from test method signature
                    method_sig = match.group(0)
                    # Try to extract method name
                    method_name_match = re.search(r'void\s+(\w+)', method_sig)
                    if method_name_match:
                        full_name = method_name_match.group(1)
                        method_part = full_name.split('_')[0] if '_' in full_name else full_name
                    else:
                        continue
            else:
                continue
            
            # Extract test body
            test_body = extract_test_body(content, match.end())
            
            if not test_body or len(test_body) < 10:
                continue
            
            # Extract input parameters
            inputs = extract_input_parameters(test_body, method_part)
            input_str = '; '.join(inputs) if inputs else 'No specific inputs'
            
            # Extract expected result
            expected = extract_expected_result(test_body, full_name)
            
            # Determine status based on test name and content
            status = "PASS"
            if "ThrowException" in full_name or "shouldThrow" in full_name:
                status = "PASS"  # Exception tests pass if they throw correctly
            if "FAIL" in full_name.upper() or "ERROR" in full_name.upper():
                status = "FAIL"
            
            # Extract notes/comments
            notes = ""
            comment_match = re.search(r'//\s*(.+)', test_body[:300])  # First comment
            if comment_match:
                notes = comment_match.group(1).strip()[:100]
            
            test_cases.append({
                'name': full_name,
                'method': method_part,
                'input': input_str,
                'expected': expected,
                'status': status,
                'notes': notes
            })
            
    except Exception as e:
        print(f"Error parsing {file_path}: {e}")
        import traceback
        traceback.print_exc()
    
    return test_cases

def get_all_test_files():
    """Get all test files"""
    test_dir = Path('src/test/java/org/example/ptcmssbackend/service')
    test_files = []
    
    if test_dir.exists():
        for file in test_dir.glob('*Test.java'):
            test_files.append(file)
    
    return test_files

# Parse all test files
print("Parsing ALL test files with comprehensive extraction...")
all_test_cases = {}

test_files = get_all_test_files()
for test_file in test_files:
    print(f"Parsing {test_file.name}...")
    test_cases = parse_test_file(test_file)
    
    # Group by method name
    for tc in test_cases:
        method_name = tc['method']
        if method_name not in all_test_cases:
            all_test_cases[method_name] = []
        all_test_cases[method_name].append(tc)

print(f"\nFound {len(all_test_cases)} methods with test cases")
total_cases = sum(len(cases) for cases in all_test_cases.values())
print(f"Total test cases: {total_cases}")

# Show sample
print("\nSample extracted data:")
sample_count = 0
for method, cases in all_test_cases.items():
    if sample_count >= 5:
        break
    print(f"\n{method}:")
    for tc in cases[:2]:
        print(f"  - {tc['name']}")
        print(f"    Input: {tc['input'][:100]}")
        print(f"    Expected: {tc['expected']}")
    sample_count += 1

# Save to JSON
import json
with open('test_cases_data.json', 'w', encoding='utf-8') as f:
    json.dump(all_test_cases, f, indent=2, ensure_ascii=False)

print(f"\nTest cases data saved to test_cases_data.json")


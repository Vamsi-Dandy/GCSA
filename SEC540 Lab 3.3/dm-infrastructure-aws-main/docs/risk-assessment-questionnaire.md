# Rapid Risk Assessment Questionnaire

The Rapid Risk Assessment Questionnaire's main objective is to understand the risk impact of a new product, update to an existing product, or proposed change.

## Risk Level Assessment

1. Do you want the security team's involvement throughout the project?

    - Yes:    <span style="color:red">High</span>

    - No:     Next Question

1. Is the new product / update to existing product using an approved secure technology stack, platform, or framework? DM supports the following secure by default frameworks: Web Application (Spring Boot, C#), Web API (Spring Boot, C#, NodeJS), ReactJS, CloudFormation.

    - No:      <span style="color:red">High</span>

    - Yes:       Next Question

1. Does the change implement new security controls or make major changes to existing security controls? Security controls include, but are not limited to, authentication, authorization, cryptography, validation, monitoring, alerting, and other compliance driven security controls.

    - Yes:      <span style="color:red">High</span>

    - No:       Next Question

1. Are you changing the attack surface of the system? Examples include, but are not limited to, adding a new API, opening a new port, adding a new user permission, adding or changing a data store, interfacing with a new service or system.

    - Yes:      <span style="color:red">High</span>

    - No:       Next Question

1. Is this a new product / update to existing product storing or accessing sensitive customer data?

    - Yes (New Product):        <span style="color:red">High</span>

    - Yes (Existing Product):   <span style="color:orange">Medium</span>

    - No:                       Next Question

1. Is this project a high priority or have major implications for business operations?

    - Yes:      <span style="color:orange">Medium</span>

    - No:       <span style="color:green">Low</span>

## Product Security Assessment

1. Identify the product type. Examples include, but are not limited to, Web Application, Web API, Mobile App, Desktop.  

    - 

1. Identify the product frameworks in use. Examples include, but are not limited to, .NET Framework, .NET Core, Xamarin, Java, Spring Boot, Node.js, Angular, React, ColdFusion, Ruby on Rails, etc.  

    - 

1. Data processing, query, and serialization formats used by the product. Examples include, but are not limited to, SQL, XML, JSON, Binary Formatter, NoSQL, LDAP, Operating System (OS) Commands.  

    - 

1. Does the product authenticate or authorize users, tokens, sessions, or other?  

    - If yes, describe the authentication frameworks (single sign on, custom authentication) in use and backend credential storage.  

        - 

    - If yes, describe any security-specific cookies, authentication tokens, or JSON Web Tokens (JWTs) stored in the browser or client-side to identify the user.  

        - 

    - If web application and security-specific cookies are in use, describe the CSRF protections in place.  

        - 

1. Does the product utilize permissions, claims, or roles to provide access control to different users? Describe the permissions, claims, and roles:  

    - 

1. Does the product perform any cryptography operations (encryption, signing, or hashing)? Describe the purpose and data being protected:  

    - 

1. Identify the high-risk code, libraries, and files for the product. Examples include, but are not limited to, infrastructure code, pipeline definitions, authentication, access control, validation, cryptography, and other components handling sensitive customer information. (e.g. $/src/Web/Controllers/AuthenticationController.cs)  

    - 

## References

[1] [Slack GoSDL](https://github.com/slackhq/goSDL)

[2] [SAFECode Tactical Threat Modeling Guide](https://safecode.org/wp-content/uploads/2017/05/SAFECode_TM_Whitepaper.pdf)

[3] [Mozilla Rapid Risk Assessment](https://infosec.mozilla.org/guidelines/risk/rapid_risk_assessment.html)

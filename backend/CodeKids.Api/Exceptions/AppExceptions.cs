namespace CodeKids.Api.Exceptions;

public class AppException : Exception
{
    public int StatusCode { get; }
    public string Title { get; }

    public AppException(int statusCode, string title, string message) : base(message)
    {
        StatusCode = statusCode;
        Title = title;
    }
}

public class NotFoundException : AppException
{
    public NotFoundException(string message) : base(404, "Not Found", message) { }
}

public class ForbiddenException : AppException
{
    public ForbiddenException(string message = "You do not have permission to access this resource.") 
        : base(403, "Forbidden", message) { }
}

public class ConflictException : AppException
{
    public ConflictException(string message) : base(409, "Conflict", message) { }
}

public class UnauthorizedException : AppException
{
    public UnauthorizedException(string message = "Invalid credentials or unauthorized access.") 
        : base(401, "Unauthorized", message) { }
}

public class ValidationException : AppException
{
    public ValidationException(string message) : base(400, "Bad Request", message) { }
}

public class InsufficientFlamesException : AppException
{
    public InsufficientFlamesException(int required, int available) 
        : base(409, "Insufficient Flames", $"Not enough flames. Required: {required}, available: {available}.") { }
}
